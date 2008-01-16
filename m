From: Patrick McHardy <kaber@trash.net>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Wed, 16 Jan 2008 06:12:02 +0100
Message-ID: <478D9222.7030603@trash.net>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net>	<478D226E.1050209@gmail.com>	<20080116004602.zn4y94e8sg0w4o8k@mail.bigtelecom.ru> <20080116010459.676cchrf8ko4wk8o@mail.bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: slavon@bigtelecom.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59947 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbYAPFMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 00:12:22 -0500
In-Reply-To: <20080116010459.676cchrf8ko4wk8o@mail.bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

slavon@bigtelecom.ru wrote:
> Good night! =)
> 
> Sorry... i was wrong...
> I see that problem more serious....
> 
> Lets see to scheme
> 
> Class 1
> ---qdisc
> ------- 10k classes
> Class 2
> ---qdisc
> ------- 10k classes
> 
> All traffic go to class 2... class 1 qdisc not have packets and if we 
> delete it - packets not lost... in theory... lets try delete class 1 
> qdisc (all childrens delete too)...
> PC freeze on 2-5 seconds... its not forward any traffic at this 
> moment... its great tree lock?
> 
> Its normal or code need to more accurate lock?


htb class destruction can be quite expansive if one of the rb trees
needs to be rebalanced. Doing that for 10000 classes would explain
the delay.

