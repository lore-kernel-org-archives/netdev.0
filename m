From: "Paul Menage" <menage@google.com>
Subject: Re: [Devel] [PATCH 1/14][NETNS]: Introduce the net-subsys id generator.
Date: Thu, 10 Apr 2008 10:37:53 -0700
Message-ID: <6599ad830804101037m29d59f8dh85e27ceefc76f8f2@mail.gmail.com>
References: <47FE2AD4.9080609@openvz.org> <47FE2BB5.4070708@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Linux Netdev List" <netdev@vger.kernel.org>,
	"Linux Containers" <containers@lists.osdl.org>,
	"Denis Lunev" <den@openvz.org>,
	"Benjamin Thery" <benjamin.thery@bull.net>
To: "Pavel Emelyanov" <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:19053 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756727AbYDJRiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 13:38:04 -0400
Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m3AHbtgL012177
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 18:37:56 +0100
Received: from py-out-1112.google.com (pyhf31.prod.google.com [10.34.233.31])
	by zps18.corp.google.com with ESMTP id m3AHbTij017651
	for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 10:37:54 -0700
Received: by py-out-1112.google.com with SMTP id f31so96425pyh.17
        for <netdev@vger.kernel.org>; Thu, 10 Apr 2008 10:37:54 -0700 (PDT)
In-Reply-To: <47FE2BB5.4070708@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 10, 2008 at 8:01 AM, Pavel Emelyanov <xemul@openvz.org> wrote:
>  +int register_pernet_gen_device(int *id, struct pernet_operations *ops)
>  +{
>  +       int error;
>  +       mutex_lock(&net_mutex);
>  +again:
>  +       error = ida_get_new_above(&net_generic_ids, 1, id);
>  +       if (error) {
>  +               if (error == -EAGAIN) {
>  +                       ida_pre_get(&net_generic_ids, GFP_KERNEL);
>  +                       goto again;
>  +               }

Shouldn't you handle non-EAGAIN errors here?

Paul
