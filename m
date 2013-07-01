From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [Patch net-next] ipip: fix a regression in ioctl
Date: Mon, 1 Jul 2013 08:03:33 -0700
Message-ID: <CALnjE+q5AW+6hwViLgh8CKScwP0uZao8r75B8_9h1unqKduO-w@mail.gmail.com>
References: <1372479115-7003-1-git-send-email-amwang@redhat.com>
	<CALnjE+qoo3D6YDpZogPq8LOJLZxoOTLa73WJFHnH2MbnFB2f7Q@mail.gmail.com>
	<1372644681.2974.12.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:52904 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751108Ab3GAPEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 11:04:11 -0400
Received: by mail-qc0-f176.google.com with SMTP id z10so2942852qcx.35
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 08:03:33 -0700 (PDT)
In-Reply-To: <1372644681.2974.12.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 30, 2013 at 7:11 PM, Cong Wang <amwang@redhat.com> wrote:
> On Sat, 2013-06-29 at 20:43 -0700, Pravin Shelar wrote:
>> On Fri, Jun 28, 2013 at 9:11 PM, Cong Wang <amwang@redhat.com> wrote:
>> > From: Cong Wang <amwang@redhat.com>
>> >
>> > This is a regression introduced by
>> > commit fd58156e456d9f68fe0448 (IPIP: Use ip-tunneling code.)
>> >
>> > Similar to GRE tunnel, previously we only check the parameters
>> > for SIOCADDTUNNEL and SIOCCHGTUNNEL, after that commit, the
>> > check is moved for all commands.
>> >
>> > So, just check for SIOCADDTUNNEL and SIOCCHGTUNNEL.
>> >
>> > Also, the check for i_key, o_key etc. is suspicious too,
>> > which did not exist before.
>> >
>> This check is sanity check since ipip is not suppose to have these
>> parameters set, generic layer do allow all parameters.
>> Earlier ipip was not using generic layer, therefore that check was not present.
>
> So, if old code doesn't reject this case with EINVAL, then your change
> _does_ break user-space applications... no matter whether ipip is
> supposed to have these parameters.
>
ok, Then we shld reset these fields before passing them to ip_tunnels layer.

>
