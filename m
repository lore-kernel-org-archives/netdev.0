From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next v3 06/10] bnxt: Add devlink support for config get/set
Date: Tue, 24 Oct 2017 23:40:38 -0700
Message-ID: <CACKFLinGDs4FkPvyZ+2xiwQ9P=3LzovnwPXNVrrRFBTtTYxvFQ@mail.gmail.com>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com>
 <1508875962-39233-7-git-send-email-steven.lin1@broadcom.com> <AM0PR0502MB3683860B5E15C71A00435499BF440@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Steve Lin <steven.lin1@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>
To: Yuval Mintz <yuvalm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:50675 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751421AbdJYGkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 02:40:39 -0400
Received: by mail-oi0-f46.google.com with SMTP id q4so41298086oic.7
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 23:40:39 -0700 (PDT)
In-Reply-To: <AM0PR0502MB3683860B5E15C71A00435499BF440@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 10:55 PM, Yuval Mintz <yuvalm@mellanox.com> wrote:

> ...
>
>> -     if (!pci_find_ext_capability(bp->pdev, PCI_EXT_CAP_ID_SRIOV))
>> -             return 0;
>> -
>> -     if (bp->hwrm_spec_code < 0x10800) {
>> +     if ((!pci_find_ext_capability(bp->pdev, PCI_EXT_CAP_ID_SRIOV)) ||
>> +         bp->hwrm_spec_code < 0x10800) {
>> +             /* eswitch switchdev mode not supported */
>> +             bnxt_dl_ops.eswitch_mode_set = NULL;
>> +             bnxt_dl_ops.eswitch_mode_get = NULL;
>
> Why would you need to tie this interface to the presence of SRIOV in PCIe?
> Also, Assuming the ability to disable sriov in #2 would cause this capability
> not to be exposed after reboot, isn't this a one-way ticket?
>

No, he is modifying the existing devlink logic for the switchdev
eswitch mode.  That logic controls the SRIOV eswitch mode and depends
on SRIOV.

But I agree the patch makes it look cumbersome.  It will be better to
check for SRIOV and proper firmware support and then setup the
eswitch_mode devlink methods.
