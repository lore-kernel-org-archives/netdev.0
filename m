From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 09/15] ixgbevf: Resolve truncation warning for
 q_vector->name
Date: Thu, 1 Jun 2017 12:30:03 +0300
Message-ID: <b6cc6ba2-fc27-3e32-073b-06b1cb462e18@cogentembedded.com>
References: <20170531211936.63417-1-jeffrey.t.kirsher@intel.com>
 <20170531211936.63417-10-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:33507 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751557AbdFAJaF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 05:30:05 -0400
Received: by mail-lf0-f46.google.com with SMTP id a136so8432112lfa.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 02:30:05 -0700 (PDT)
In-Reply-To: <20170531211936.63417-10-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 6/1/2017 12:19 AM, Jeff Kirsher wrote:

> From: Tony Nguyen <anthony.l.nguyen@intel.com>
>
> The following warning is now shown as a result of new checks added for
> gcc 7:
>
> drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c: In function ‘ixgbevf_open’:
> drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:1363:13: warning: ‘%d’ directive output may be truncated writing between 1 and 10 bytes into a region of size between 3 and 18 [-Wformat-truncation=]
>       "%s-%s-%d", netdev->name, "TxRx", ri++);
>              ^~
> drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:1363:6: note: directive argument in the range [0, 2147483647]
>       "%s-%s-%d", netdev->name, "TxRx", ri++);
>       ^~~~~~~~~~
> drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c:1362:4: note: ‘snprintf’ output between 8 and 32 bytes into a destination of size 24
>     snprintf(q_vector->name, sizeof(q_vector->name) - 1,
>     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>       "%s-%s-%d", netdev->name, "TxRx", ri++);
>       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>
> Resolve this warning by making a couple of changes.
>  - Don't reserve space for the null terminator.  Since snprintf adds the
>    null terminator automatically, there is no need for us to reserve a byte
>    for it.
>
>  - Change a couple variables that can never be negative from int to
>    unsigned int.
>
> While we're making changes to the format string, move the constant strings
> into the format string instead of providing them as specifiers.

    I suspect that trick saved some data space due to using the identical (and 
so merged) format strings...

> Signed-off-by: Tony Nguyen <anthony.l.nguyen@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

[...]

MBR, Sergei
