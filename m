From: Tom Herbert <tom@herbertland.com>
Subject: Re: [oss-drivers] Re: [PATCH/RFC net-next 1/2] flow dissector: ND support
Date: Wed, 8 Feb 2017 11:10:06 -0800
Message-ID: <CALx6S377UEHpmRA1zhX=SeSUepJ4VUFKxVfj=4mC9ZuOb23dBg@mail.gmail.com>
References: <20170207.123831.1038511845714033360.davem@davemloft.net>
 <20170208092823.GA17615@penelope.horms.nl> <CALx6S36VrtQM5G2XPzpcrP=y3RyBwTnYJcaKqXtwyFgpGiz+Jg@mail.gmail.com>
 <20170208.135415.601520734521006340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <simon.horman@netronome.com>,
        =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:36587 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751966AbdBHTKf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:10:35 -0500
Received: by mail-qk0-f181.google.com with SMTP id 11so132921282qkl.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 11:10:07 -0800 (PST)
In-Reply-To: <20170208.135415.601520734521006340.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 8, 2017 at 10:54 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Wed, 8 Feb 2017 10:33:46 -0800
>
>> On Wed, Feb 8, 2017 at 1:28 AM, Simon Horman <simon.horman@netronome.com> wrote:
>>> I think the above paragraph gets back to Tom's original question regarding
>>> making things more complex just for OvS (use-cases). Possibly ND is an edge
>>> case even for OvS and on reflection my timing for posting it seems to have
>>> been less than ideal.
>>
>> If it wasn't ND it would be something else... with all the activity
>> happening in networking features and HW this is a timely discussion.
>> Flow dissector presents a good example of a function that might become
>> a dumping ground for an endless stream of features if we don't figure
>> out how exercise some restraint.
>
> I agree on most points.
>
> But, I would say that in this specific case, since we have ARP support in
> there already it behooves us to support the ipv6 side in the form of ND
> too.
>
> Then we can put a line in the sand and say that future feature additions
> in this area require serious discussion.
>
> Ok Tom?

Right, ND is okay on the basis that we already have ARP (although I
still may grumble from time to time that ARP, ND, and ICMP are being
identified as flows ;-) ).

I think there are two projects in the are that someone, maybe an
aspiring kernel network developer, might want to look into if they
have the time:

- Inevitably someone will want to support VXLAN or other UDP
encapsulations in flow dissector. The only correct way to do this is
going to be to do a lookup on UDP socket and have a flow_dissector
function related to the socket. This is the model for dealing with UDP
encapsulations in GRO that could be extended for flow dissection. We
cannot hard code port numbers in flow_dissector. The interesting part
here will be making a robust interface to avoid the pitfalls we've
seen in some of the protocols in flow_dissector.

- Allow calling a BPF function to do custom flow dissection. IIRC
there someone (Daniel?) had already implement flow_dissector in BPF
with pretty good results.

Tom
