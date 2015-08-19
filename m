From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3] rocker: add debugfs support to dump internal tables
Date: Wed, 19 Aug 2015 12:46:11 -0700
Message-ID: <CAE4R7bB1SopU3dFpA4fGUrSD-x70f=NMsQofMoO=DC+ZzaurFQ@mail.gmail.com>
References: <CAE4R7bAwuZkoOqO1eA9pWQ35UPiSs7-Fm+AaedVU1wwiRZ=Jwg@mail.gmail.com>
 <20150818181930.GK4381@lunn.ch> <CAE4R7bA621-ySQuOJ_kLTSju7ZwD3Ur4oSAS0JCE4EjzEsRr7Q@mail.gmail.com>
 <20150818.134720.1520233036019988872.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, "andrew@lunn.ch" <andrew@lunn.ch>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:33163 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbbHSTqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 15:46:31 -0400
Received: by obbhe7 with SMTP id he7so13802964obb.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 12:46:30 -0700 (PDT)
In-Reply-To: <20150818.134720.1520233036019988872.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 18, 2015 at 1:47 PM, David Miller <davem@davemloft.net> wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> Date: Tue, 18 Aug 2015 13:37:56 -0700
>

>>>> > Hi Scott
>>>> >
>>>> > David is not so keen no debugfs stuff. He already NACKed adding more
>>>> > than what is currently in DSA:
>>>> >
>>>> > https://lkml.org/lkml/2015/7/11/8
>>>>
>>>> That patch added writable debugfs files, which I can see might be used
>>>> as a back-door to program hardware.  That does seem bad.
>>>
>>> I fully agreed with respect to write. But if you read the whole
>>> message, David is also not happy with read only.
>>>
>>> I think before you spend too much more time on this, you need some
>>> indication from David if he is going to merge it or not.
>>
>> David, please give us guidance on debugfs in drivers/net.  Is there
>> some criteria we can define to know when it's OK to use debugfs?
>
> The less you use it the better, seriously.
>
> I see some drivers where the foo_debugfs.c file is larger than the rest
> of the driver.  Once people start using it, it's like crack, and they
> dump every single debugging widget they found useful at some point into
> there.
>
> This is not what we want.  Most things I see in debugfs support was
> probably useful for debugging one particular bug but then it was never
> really useful again in the future.  Those kinds of things can be done
> locally in someone's tree.
>
> I often see various kinds of "statistics" ending up in these things,
> or register dumps, both of which are 'ethtool' or similar material.

# git grep debugfs_create drivers/net

^^^  this is scary.  I see some crazy things being done here.   The
writable nodes look like workaround driver/device bugs or to provide
backdoor interfaces that don't exist natively.

I say we clean up this mess.  Just eliminating the writable files
would force bugs to get fixed and get new interfaces defined.  And
replace readable files when interface exist (stats/reg).  Finally,
look for readable files that can be converted to new shared common
interfaces.  What's left should be read-only (S_IRUGO) files (no
binary blobs) containing data unique for driver/device useful for
field troubleshooting.

I'm motivated.  Next net-next cycle I'm going to go down the list with
a big eraser.  I'm sure I'll be a popular guy.

-scott
