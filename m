From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 09/11] bnxt_en: bnxt: add TC flower filter
 offload support
Date: Mon, 11 Sep 2017 15:36:07 +0200
Message-ID: <20170911133607.GD1869@nanopsycho>
References: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
 <1503942035-24924-10-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Sathya Perla <sathya.perla@broadcom.com>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:34265 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751612AbdIKNgK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 09:36:10 -0400
Received: by mail-wr0-f178.google.com with SMTP id v109so14705450wrc.1
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 06:36:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1503942035-24924-10-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 28, 2017 at 07:40:33PM CEST, michael.chan@broadcom.com wrote:
>From: Sathya Perla <sathya.perla@broadcom.com>
>
>This patch adds support for offloading TC based flow
>rules and actions for the 'flower' classifier in the bnxt_en driver.
>It includes logic to parse flow rules and actions received from the
>TC subsystem, store them and issue the corresponding
>hwrm_cfa_flow_alloc/free FW cmds. L2/IPv4/IPv6 flows and drop,
>redir, vlan push/pop actions are supported in this patch.
>
>In this patch the hwrm_cfa_flow_xxx routines are just stubs.
>The code for these routines is introduced in the next patch for easier
>review. Also, the code to query the TC/flower action stats will
>be introduced in a subsequent patch.

Hi.

You are missing checks for the offload. Please see nfp as an example:
Function nfp_flower_setup_tc:

            !is_classid_clsact_ingress(cls_flower->common.classid) ||
            cls_flower->common.chain_index)

Do you support both ingress and egress or ingress only?

You certainly don't support multichain.
