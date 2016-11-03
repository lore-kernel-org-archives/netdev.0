From: Nicolai Stange <nicstange@gmail.com>
Subject: Re: [PATCH net-next 10/13] debugfs: constify argument to debugfs_real_fops()
Date: Thu, 03 Nov 2016 17:55:39 +0100
Message-ID: <87zilgv6yc.fsf@gmail.com>
References: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
        <1478181538-20778-11-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Nicolai Stange <nicstange@gmail.com>,
        Christian Lamparter <chunkeey@gmail.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36668 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757606AbcKCQzm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 12:55:42 -0400
Received: by mail-wm0-f67.google.com with SMTP id c17so8919856wmc.3
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 09:55:41 -0700 (PDT)
In-Reply-To: <1478181538-20778-11-git-send-email-jakub.kicinski@netronome.com>
        (Jakub Kicinski's message of "Thu, 3 Nov 2016 13:58:55 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jakub,

thanks for this.

However, the debugfs maintainer, Greg K-H, as well as the lkml is
missing from the To/Cc. Can you resend please?

Jakub Kicinski <jakub.kicinski@netronome.com> writes:

> seq_file users can only access const version of file pointer,

... because the ->file member of struct seq_operations is marked as such.

> make parameter to debugfs_real_fops() const.
>
> CC: Nicolai Stange <nicstange@gmail.com>
> CC: Christian Lamparter <chunkeey@gmail.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  include/linux/debugfs.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/debugfs.h b/include/linux/debugfs.h
> index 4d3f0d1aec73..bf1907d96097 100644
> --- a/include/linux/debugfs.h
> +++ b/include/linux/debugfs.h
> @@ -52,7 +52,8 @@ struct debugfs_regset32 {
>   * Must only be called under the protection established by
>   * debugfs_use_file_start().
>   */
> -static inline const struct file_operations *debugfs_real_fops(struct file *filp)
> +static inline const struct file_operations *
> +debugfs_real_fops(const struct file *filp)
>  	__must_hold(&debugfs_srcu)
>  {
>  	/*
