From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP seems to lose its socket state.
Date: Fri, 13 Jun 2014 14:48:52 -0400
Message-ID: <539B4794.4010700@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com> <063D6719AE5E284EB5DD2968C1650D6D17258A67@AcuExch.aculab.com> <063D6719AE5E284EB5DD2968C1650D6D17259993@AcuExch.aculab.com> <539638EB.9010802@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1725C172@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:61451 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbaFMSsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2014 14:48:55 -0400
Received: by mail-qa0-f46.google.com with SMTP id i13so4108517qae.5
        for <netdev@vger.kernel.org>; Fri, 13 Jun 2014 11:48:54 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725C172@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2014 06:53 AM, David Laight wrote:
> From: Vlad Yasevich 
>> Can you try the attached patch and let me know if it solves this problem
>> for you.
> 
> I've finally got around to trying it, and then fighting grub2 to get a
> serial console (after finding a COM header and cables).
> (Why can't I configure two entries for the same kernel, with and without
> the serial console...)
> 
> As soon as the COOKIE_ECHO is received I get:
> 
> [   65.756811] kernel BUG at /home/dsl/linux/net/sctp/command.c:50!
> 
> It has hit the limit for SCTP_MAX_NUM_COMMANDS.
> I increased it to 20 and traced the entries when the exceeded
> the old limit (of 14).
> 
> [  102.250614] sctp_add_cmd_sf: seq  0, 36(          (null))
> [  102.266575] sctp_add_cmd_sf: seq  1, 15(0000000000000008)
> [  102.282500] sctp_add_cmd_sf: seq  2, 2b(          (null))
> [  102.298426] sctp_add_cmd_sf: seq  3, 15(0000000000000005)
> [  102.314352] sctp_add_cmd_sf: seq  4, 40(          (null))
> [  102.330279] sctp_add_cmd_sf: seq  5, 2a(ffff88022f3b4000)
> [  102.346206] sctp_add_cmd_sf: seq  6,  b(ffff8800bc4df128)
> [  102.361874] sctp_add_cmd_sf: seq  7,  c(ffff8800bc4de800)
> [  102.377540] sctp_add_cmd_sf: seq  8, 2c(ffff8800bc4df000)
> [  102.393470] sctp_add_cmd_sf: seq  9, 12(0000000000000003)
> [  102.409397] sctp_add_cmd_sf: seq 10, 14(0000000000000006)
> [  102.425583] sctp_add_cmd_sf: seq 11,  3(0000000000000005)
> [  102.441510] sctp_add_cmd_sf: seq 12, 20(          (null))
> [  102.457699] sctp_add_cmd_sf: seq 13,  c(ffff8800bc4df000)
> [  102.521433] sctp_add_cmd_sf: seq 14, 41(ffff88022f3b4000)
> [  102.538658] sctp_add_cmd_sf: seq 15,  2(          (null))
> [  102.555626] sctp_add_cmd_sf: seq 16, 41(ffff88023525e000)
> 
> I've not tried to see what these are.

Yeah.  We do end up queuing a bit more commands. Need to see if
all them are necessary..

> 
> tcpdump then shows it sending a shutdown bundled with the cookie ack
> and the disconnect completes.

Thanks.  I'll take a look at all the commands we queue up and make
an official submission.

-vlad

> 
> 	David
> 
> 
> 
> 
