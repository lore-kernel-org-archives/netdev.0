From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 2/8] netdevice: add IPv4 fib add/del ops
Date: Fri, 06 Mar 2015 09:55:07 -0500
Message-ID: <54F9BFCB.5030100@mojatatu.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com> <1425619280-27492-3-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: sfeldma@gmail.com, netdev@vger.kernel.org, davem@davemloft.net,
	jiri@resnulli.us, roopa@cumulusnetworks.com,
	alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:43190 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459AbbCFOzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 09:55:16 -0500
Received: by igbhn18 with SMTP id hn18so4300448igb.2
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 06:55:15 -0800 (PST)
In-Reply-To: <1425619280-27492-3-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/15 00:21, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Add two new ndo ops for IPv4 fib offload support, add and del.  Add uses
> modifiy semantics if fib entry already offloaded.


The above semantic will not express correctly the intent that the tools
like iproute2 expose and user space expects.
I think you need to pass the netlink flags to do it correctly at
the driver level.
i.e classical table operations per netlink flags (NLM_F_CREATE,
NLM_F_REPLACE, NLM_F_EXCL, NLM_F_APPEND)

1) Create: NLM_F_CREATE
2) Create exclusively i.e reject if already created
(NLM_F_CREATE|NLM_F_EXCL)
3) Create or modify (which is the semantic you are refering to)
NLM_F_CREATE|NLM_F_REPLACE
4) Append - which means "I dont care if it exists, just append it"
NLM_F_CREATE|NLM_F_APPEND

cheers,
jamal
