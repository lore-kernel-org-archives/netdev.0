From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: sock_create_kern() and (lack of) get_net()
Date: Wed, 3 May 2017 09:33:10 -0700
Message-ID: <CAM_iQpVmmtR8EKc2AsP2wMq8K8m_SeRSwSw4tp5u=Rt4zdzi-g@mail.gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6DCFFE4805@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37073 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751860AbdECQdc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 12:33:32 -0400
Received: by mail-wm0-f50.google.com with SMTP id m123so64554894wma.0
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 09:33:31 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFE4805@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 3, 2017 at 4:39 AM, David Laight <David.Laight@aculab.com> wrote:
> I suspect that many of the sockets created with 'kern=1' are not 'special'
> and should hold a reference to the namespace.

They are special if they are created in net init, which means they
have the same life-time with netns. They should NOT hold a refcnt,
otherwise who would release the last netns refcnt? net exit is called
when refcnt reaches 0, if you really held it, it is always at least 1.
