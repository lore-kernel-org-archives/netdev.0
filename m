From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH net-next v2 2/3] sh_eth: add support RMIIMODE register
Date: Fri, 28 Jun 2013 18:31:18 +0400
Message-ID: <51CD9E36.4060007@cogentembedded.com>
References: <1368499073-21975-1-git-send-email-horms+renesas@verge.net.au> <1368499073-21975-3-git-send-email-horms+renesas@verge.net.au> <519240C7.1060406@cogentembedded.com> <20130515005117.GC12246@verge.net.au> <51AFA30B.4080809@cogentembedded.com> <20130628014130.GA17373@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:51522 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab3F1ObT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 10:31:19 -0400
Received: by mail-lb0-f173.google.com with SMTP id v1so1074212lbd.4
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 07:31:18 -0700 (PDT)
In-Reply-To: <20130628014130.GA17373@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 28-06-2013 5:41, Simon Horman wrote:

>>>>> This change is motivated by the lager board which uses the r8a7790 SoC,
>>>>> an R-Car SoC. For this board setting the RMIIMODE register is necessary.
>>>>> This patch assumes this is valid for all R-Car SoCs.
>>>>     No, RMIIMODE register is not documented on R8A7778/9 SoCs and
>>>> this location is described as reserved. How's it called in R8A7790
>>>> manual, CXR15?

>>> It appears to be undocumented in the R8A7790 I have.

>>      Of the manuals I have now this register is only documented in
>> R-Car H2 user's manual 0.50,

>>> Empirically it seems necessary for the lager/R8A7790.

>>     The manual confirms that.

>>> To be honest I am entirely unsure of its relevance to other SoCs.

>>> I wonder if a better approach would be to add a flag to platform
>>> data rather than struct sh_eth_cpu_data. This would allow the register
>>> to only be accessed on boards where it is known to be useful.

>>     No, this doesn't depend on the board, judging on the H2 manual.
>> You just must write it to 1 on R-Car H2 in order for Ether to operate.

> What is your preferred way to add support for this to the driver?

    Like you did, add a field to 'struct sh_eth_cpu_data' that's 1 if 
RMIIMODE register is present but don't set it in 'r8a777x_data' and 
create separate 'r8a7790_data' instead (where to set this field).

WBR, Sergei
