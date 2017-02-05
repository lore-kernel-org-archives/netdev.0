From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Sat, 4 Feb 2017 19:10:46 -0800
Message-ID: <20170205031045.GC73775@ast-mbp.thefacebook.com>
References: <CALCETrXQ8JFV28xU7tnh3tVbe_mp5yOtHp6shi10GMNnVCQowg@mail.gmail.com>
 <588A35F8.6050909@fb.com>
 <CALCETrU7FYz=8c2a=FWvvCxFQC3_e0nYjSU6gj62w9K8mWj=Ww@mail.gmail.com>
 <588A40D7.9070603@fb.com>
 <CALCETrXgdY_Kt8wn4uiATUnNJ3YXttCUREgEeQReG7u29Lc44g@mail.gmail.com>
 <588A4D3C.9070601@fb.com>
 <87r33fevva.fsf@xmission.com>
 <CALCETrWDxVHc4_hpjLQRj-XbvGX0+tbGZ8o388-xn6rNcQTySQ@mail.gmail.com>
 <20170203230830.GC26227@ast-mbp.thefacebook.com>
 <CALCETrUb1Rf-BdSTHdKSgwnftHjpmcDt1HX1KX-cpN=N7ev+eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Alexei Starovoitov <ast@fb.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33157 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751293AbdBEDKw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 22:10:52 -0500
Received: by mail-pf0-f193.google.com with SMTP id e4so4337994pfg.0
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 19:10:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrUb1Rf-BdSTHdKSgwnftHjpmcDt1HX1KX-cpN=N7ev+eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 09:07:19AM -0800, Andy Lutomirski wrote:
> >> can see a namespaced view of the world.  For this to work, presumably
> >> we need to make sure that eBPF programs that are installed by programs
> >> that are in a container don't see traffic that isn't in that
> >> container.
> >
> > such approach will break existing users.
> 
> What existing users?  The whole feature has never been in a released kernel.

the v3 patch commit log explains the use cases that work across netns.
And they would break if netns boundary is suddenly started to be
enforced for networking program types.
If you're suggesting to limit root netns for cgroup_sock program type only
then David explained weeks ago why it's not acceptable for vrf use
case which was the main reason to add that program type in the first place.
Also it would make one specific bpf program type to be different
from all others which will be confusing.
