From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: Distributed storage release.
Date: Mon, 13 Oct 2008 16:44:28 +0300
Message-ID: <84144f020810130644w7f89f3d9m3c3d3e63d3034534@mail.gmail.com>
References: <20081006160034.GA611@2ka.mipt.ru>
	 <20081012192419.fd8394c9.akpm@linux-foundation.org>
	 <20081013133850.GA13565@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:6952 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbYJMNo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 09:44:29 -0400
Received: by wa-out-1112.google.com with SMTP id v27so851599wah.21
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2008 06:44:28 -0700 (PDT)
In-Reply-To: <20081013133850.GA13565@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

On Mon, Oct 13, 2008 at 4:38 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
>> > +static void *dst_crypto_thread_init(void *data)
>> > +{
>> > +   struct dst_node *n = data;
>> > +   struct dst_crypto_engine *e;
>> > +   int err = -ENOMEM;
>> > +
>> > +   e = kzalloc(sizeof(struct dst_crypto_engine), GFP_KERNEL);
>> > +   if (!e)
>> > +           goto err_out_exit;
>> > +   e->src = kzalloc(sizeof(struct scatterlist) * 2 * n->max_pages,
>> > +                   GFP_KERNEL);
>>
>> kcalloc()?
>
> What's the difference? In saving one space and replacing another with
> comma? I do not particulary care, but would like to know why it is
> needed :)

kcalloc() will check for multiplication overflow which is nice
especially if size is passed from user-space (not sure if that applies
here).
