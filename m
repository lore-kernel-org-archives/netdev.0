From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: ss format bug
Date: Mon, 31 Aug 2015 16:23:16 -0700
Message-ID: <20150831162316.5e1a9b9e@urahara>
References: <55DDE255.1010003@qacafe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike Saal <msaal@qacafe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33668 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbbHaXXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 19:23:05 -0400
Received: by paczk9 with SMTP id zk9so5853850pac.0
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 16:23:05 -0700 (PDT)
In-Reply-To: <55DDE255.1010003@qacafe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Aug 2015 11:59:17 -0400
Mike Saal <msaal@qacafe.com> wrote:

> Hi:
> 
> I found a formatting bug in the 4.1.1 ss command. The following line was 
> incorrectly output due to passing a negative length to printf() when 
> displaying the local address. In this instance hostapd does a "bind to 
> device" on cdreth0 and then does a udp "in address any" port 67 bind. 
> Please note the whitespace between the '*' and ' %cdreth0:67'
> 
>     'udp UNCONN 0 0 ** %cdreth0:67* *:* users:(("hostapd",pid=19241,fd=5))'
> 
> Attached is my patch for the bug fix, it might be prudent to add more 
> guard code looking for negative length format codes.
> 
> Sincerely, Mike


I think the root cause of this is actually down in the main program
where it is computing addr_width. It is not accounting for the size correctly,
or maybe your case just occurs if screen is too narrow to fit the full width.
