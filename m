From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: get R8A7740 Rx descriptor word 0 shift out of
 #ifdef
Date: Tue, 11 Jun 2013 17:01:34 +0400
Message-ID: <51B71FAE.6050005@cogentembedded.com>
References: <201306110022.51293.sergei.shtylyov@cogentembedded.com> <51B6B702.6070005@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:38470 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994Ab3FKNBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 09:01:38 -0400
Received: by mail-lb0-f177.google.com with SMTP id 10so6890445lbf.22
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 06:01:36 -0700 (PDT)
In-Reply-To: <51B6B702.6070005@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11-06-2013 9:34, Shimoda, Yoshihiro wrote:

>> The only R8A7740 specific #ifdef hindering ARM multiplatform  build is left  in
>> sh_eth_rx(): it covers a very strange code shifting Rx buffer descriptor word 0
>> by 16 (which should cause Rx length error to be logged on every buffer  several
>> lines later). Get rid of the #ifdef by adding 'shift_rd0' field to the  'struct
>> sh_eth_cpu_data', making the shift dependent on it, and setting it to 1 for the
>> R8A7740 case...

> This very strange code was from the first R8A7740 supporting patch I sent.
> I should have shifted the RD_RFS values (from RD_RFS1 to RD_RFS10) if R8A7740.
> In other words, since the desc_status also has RDFEND, I should have not shifted
> the desc_status before the driver checked the RDFEND.

> So, I think we have to modify this "desc_status >>= 16" timing.
> Should I submit such a patch first?

    Yes, that would be preferable. Just give it a good description.

> Best regards,
> Yoshihiro Shimoda

WBR, Sergei
