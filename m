From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next v3 0/7] switchdev: add IPv4 routing offload
Date: Wed, 04 Mar 2015 23:18:52 -0800
Message-ID: <54F8035C.3060400@gmail.com>
References: <1425425520-34017-1-git-send-email-sfeldma@gmail.com> <20150304.003844.1400829201582760359.davem@davemloft.net> <CAE4R7bDBJye388V+itU9XqFNjruf0GcbXWFydx60fghiZp+NQw@mail.gmail.com> <20150304.160604.2259380248170644628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:33071 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754047AbbCEHTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 02:19:09 -0500
Received: by obcvb8 with SMTP id vb8so8183543obc.0
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 23:19:08 -0800 (PST)
In-Reply-To: <20150304.160604.2259380248170644628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2015 01:06 PM, David Miller wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> Date: Tue, 3 Mar 2015 23:28:06 -0800
>
>> On Tue, Mar 3, 2015 at 9:38 PM, David Miller <davem@davemloft.net> wrote:
>> In v3, the setting and clearing of RTNH_F_EXTERNAL moved to the
>> driver, the implementer of the add/del ndo ops.  So RTNH_F_EXTERNAL
>> does get cleared by the driver on fib_flush_external().  We could add
>> an additional clear above the driver, just in case the driver screwed
>> up and forgot to clear it.  Driver bug in that case; not sure where to
>> draw the line.
>
> I'd rather the state bit get managed by net/ipv4/*.c rather than
> duplicate this into every driver, that's error prone and duplicates
> logic unnecessarily.
>
>>> Secondly, if you call fib_flush_external() because an add returned an
>>> error, you have to set some boolean state which prevents the next new
>>> route insert from loading only that new route into the hardware
>>> because that's exactly what will happen with your current
>>> implementation.
>>
>> I guess we could add a net.ipv4.fib_hw_screwed.  But that kills other
>> innocent switch devices on same netns.  Or is it a private driver
>> bool, which gets set on first install err, and is checked on
>> subsequent installs?
>
> You can make it per-netdevice if you want.  Put it into the inetdevice
> area perhaps.

Also at some point we will need a way to get it out of the
fib_hw_screwed state. But I guess we can lump this into the "better
policy" later.

Sorry for the noise on the last post...

.John

-- 
John Fastabend         Intel Corporation
