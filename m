From: "Li, Zhen-Hua" <lizhenhua.dev@gmail.com>
Subject: Re: Problem with unregister_netdevice
Date: Tue, 8 Jan 2013 16:19:33 +0800
Message-ID: <CAEk7JKZy+1VRzCDySTFDECvWXPpC1=XW9_seTSyMESYJ_ozing@mail.gmail.com>
References: <20130104142241.GA17526@seeking.truth.sk>
	<20130104.125214.790250863069806993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: vasko@truth.sk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:45867 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099Ab3AHI0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 03:26:23 -0500
Received: by mail-bk0-f43.google.com with SMTP id jf20so59452bkc.2
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 00:26:22 -0800 (PST)
In-Reply-To: <20130104.125214.790250863069806993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I also met such problem before.  The ref_cnt of the device is not
going to be 0, so it fall in dead loop in unregister_device.
At last I did not fix it, but add a max retry times to avoid it.


On Sat, Jan 5, 2013 at 4:52 AM, David Miller <davem@davemloft.net> wrote:
> From: Tomas Vasko <vasko@truth.sk>
> Date: Fri, 4 Jan 2013 15:22:41 +0100
>
>> From bisecting on .../git/torvalds/linux-2.6.git it seems the culprit is
>> this commit: 81166dd6fa8eb780b2132d32fbc77eb6ac04e44e
>
> Please quote the commit message of the commit next time when
> referencing a commit, it saves us a lot of time.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
