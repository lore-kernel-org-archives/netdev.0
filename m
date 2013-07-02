From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipip: fix a regression in ioctl
Date: Mon, 01 Jul 2013 23:36:49 -0700 (PDT)
Message-ID: <20130701.233649.2100517070636126111.davem@davemloft.net>
References: <CALnjE+qoo3D6YDpZogPq8LOJLZxoOTLa73WJFHnH2MbnFB2f7Q@mail.gmail.com>
	<1372644681.2974.12.camel@cr0>
	<CALnjE+q5AW+6hwViLgh8CKScwP0uZao8r75B8_9h1unqKduO-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442Ab3GBGgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 02:36:50 -0400
In-Reply-To: <CALnjE+q5AW+6hwViLgh8CKScwP0uZao8r75B8_9h1unqKduO-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Mon, 1 Jul 2013 08:03:33 -0700

> On Sun, Jun 30, 2013 at 7:11 PM, Cong Wang <amwang@redhat.com> wrote:
>> On Sat, 2013-06-29 at 20:43 -0700, Pravin Shelar wrote:
>>> On Fri, Jun 28, 2013 at 9:11 PM, Cong Wang <amwang@redhat.com> wrote:
>>> > From: Cong Wang <amwang@redhat.com>
>>> >
>>> > This is a regression introduced by
>>> > commit fd58156e456d9f68fe0448 (IPIP: Use ip-tunneling code.)
>>> >
>>> > Similar to GRE tunnel, previously we only check the parameters
>>> > for SIOCADDTUNNEL and SIOCCHGTUNNEL, after that commit, the
>>> > check is moved for all commands.
>>> >
>>> > So, just check for SIOCADDTUNNEL and SIOCCHGTUNNEL.
>>> >
>>> > Also, the check for i_key, o_key etc. is suspicious too,
>>> > which did not exist before.
>>> >
>>> This check is sanity check since ipip is not suppose to have these
>>> parameters set, generic layer do allow all parameters.
>>> Earlier ipip was not using generic layer, therefore that check was not present.
>>
>> So, if old code doesn't reject this case with EINVAL, then your change
>> _does_ break user-space applications... no matter whether ipip is
>> supposed to have these parameters.
>>
> ok, Then we shld reset these fields before passing them to ip_tunnels layer.

Someone please respin this to clear the fields instead, thanks!
