From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2 / match / meta bug?
Date: Tue, 29 Jul 2008 08:18:26 +0200
Message-ID: <488EB632.9@trash.net>
References: <200807290843.29447.denys@visp.net.lb> <488EB07D.50406@trash.net> <200807290911.35809.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40956 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbYG2GTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 02:19:20 -0400
In-Reply-To: <200807290911.35809.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> Well, the issue not with ifb0 only. It is just not parsing rules correctly i think:
>
> rich tc # ./tc filter add dev ifb0 protocol all basic match meta\(protocol eq 1234\) classid 1:100
> rich tc # ./tc filter add dev ifb0 protocol all basic match meta\(data_len eq 1234\) classid 1:100
>
> filter parent 1: protocol all pref 49151 basic
> filter parent 1: protocol all pref 49151 basic handle 0x1 flowid 1:100
>   meta(-1 eq 1234)
>
> filter parent 1: protocol all pref 49152 basic
> filter parent 1: protocol all pref 49152 basic handle 0x1 flowid 1:100
>   meta(-1 eq 1234)
>   

Works fine here with a fresh git checkout:

# tc filter add dev dummy0 protocol all parent 1: basic match 
meta\(protocol eq 1234\) classid 1:100
# tc -s -d filter show dev dummy0
filter parent 1: protocol all pref 49151 basic
filter parent 1: protocol all pref 49151 basic handle 0x1 flowid 1:100
  meta(protocol mask 0x00000000 eq 1234)

filter parent 1: protocol all pref 49152 basic


