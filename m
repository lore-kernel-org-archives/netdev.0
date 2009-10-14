From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: query: bnx2 and tg3 don't check tcp and/or ip header length validity?
Date: Wed, 14 Oct 2009 16:46:36 -0400
Message-ID: <4AD638AC.3000901@gmail.com>
References: <4AD5F333.3040002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:62725 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbZJNUrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 16:47:19 -0400
Received: by ewy4 with SMTP id 4so199341ewy.37
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 13:46:41 -0700 (PDT)
In-Reply-To: <4AD5F333.3040002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:
> My question is whether it would be OK to add a simple test, and set it to
> zero in case of bad values?
> 
Although both are compiled in my build, I've got no way to test them.  I'm
just going to do the easy thing and set to zero for now.  Somebody that
knows the code -- who should have done real error checking -- could actually
write better error checking and comments about the purpose of cramming the
length of the TCP option field into a tag....

-		tcp_opt_len = tcp_optlen(skb);
+		tcp_opt_len = tcp_option_len_th(tcp_hdr(skb));
+		if (tcp_opt_len < 0)
+			tcp_opt_len = 0;

