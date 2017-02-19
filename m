From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 7/7] nfp: allow application firmware to limit
 number of SR-IOV VFs
Date: Sun, 19 Feb 2017 11:51:50 -0800
Message-ID: <CAJpBn1yKjrOMqA1OAi_JS9mqL6ygtioz-1+3K7Q83--a_LDELw@mail.gmail.com>
References: <20170217220027.189992-1-jakub.kicinski@netronome.com>
 <20170217220027.189992-8-jakub.kicinski@netronome.com> <BL2PR07MB2306B36343A7E0493018AB158D5F0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oss-drivers@netronome.com" <oss-drivers@netronome.com>,
        "dinan.gunawardena@netronome.com" <dinan.gunawardena@netronome.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33992 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdBSUAh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 15:00:37 -0500
Received: by mail-qk0-f181.google.com with SMTP id s186so80888365qkb.1
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 12:00:37 -0800 (PST)
In-Reply-To: <BL2PR07MB2306B36343A7E0493018AB158D5F0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 19, 2017 at 8:00 AM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>> +static void nfp_pcie_sriov_read_nfd_limit(struct nfp_pf *pf)
>> +{
>> +     int err;
>> +
>> +     pf->limit_vfs = nfp_rtsym_read_le(pf->cpp, "nfd_vf_cfg_max_vfs",
>> &err);
>> +     if (!err)
>> +             return;
>> +
>> +     pf->limit_vfs = ~0;
>> +     /* Allow any setting for backwards compatibility if symbol not found
>> */
>> +     if (err != -ENOENT)
>> +             nfp_warn(pf->cpp, "Warning: VF limit read failed: %d\n", err);
>> +}
>> +
>
> If you're only going to use this under CONFIG_PCI_IOV,
> perhaps put this underneath the ifdef as well?

Sure, I have a slight preference to not use ifdefs unless necessary,
but I guess the body of this function could be under an ifdef without
making things too ugly..  Thanks :)  Testing almost done, v2 coming
shortly.
