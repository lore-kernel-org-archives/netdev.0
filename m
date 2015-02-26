From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: new link failing on duplicate names in different namespaces
Date: Thu, 26 Feb 2015 07:55:04 -0600
Message-ID: <87sidsok07.fsf@x220.int.ebiederm.org>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>
	<54EDF7BB.2060809@6wind.com> <8761apubru.fsf@x220.int.ebiederm.org>
	<CAHA+R7NA6UpC2cy7T14YAxW1gzVi=97yO23pWkkvj1DbV6sTdA@mail.gmail.com>
	<CAHA+R7Ocu7ig4NL+rrNq3szFBqKVRSSXhPiZDHP4tEzL6OSFzQ@mail.gmail.com>
	<54EEE3DB.4040900@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>,
	Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46275 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbbBZN6f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 08:58:35 -0500
In-Reply-To: <54EEE3DB.4040900@6wind.com> (Nicolas Dichtel's message of "Thu,
	26 Feb 2015 10:14:03 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 26/02/2015 06:56, Cong Wang a =C3=A9crit :
>> On Wed, Feb 25, 2015 at 9:29 PM, Cong Wang <cwang@twopensource.com> =
wrote:
> [snip]
>>
>> Please give the attached patch a try.
>>
> It's hard to comment a patch which is sent in attachment
> (see
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/D=
ocumentation/SubmittingPatches#n333).
>
> +				err =3D rtnl_group_changelink(skb, dest_net,
> It should probably be something like 'link_net ? : dest_net' instead =
of
> dest_net.
>
> I also don't understand why you need two label ('out' and 'err'). I t=
hink one is
> enough (link_net is initialized to NULL for this purpose).
> And why not keeping the same name as before, ie 'out'? It will minimi=
ze the
> patch.

Sigh.

We can not give the guarantee that a new network device will only live
in and have a unique name in a single network namespace until we get
rid of dev_change_net_namespace in the code.

Cong your patch does not get rid of that and so is insufficient to solv=
e
this problem and buggy.

Eric
