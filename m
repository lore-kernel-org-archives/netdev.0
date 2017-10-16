From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 2/3] bpf: Remove dead variable
Date: Mon, 16 Oct 2017 21:22:42 +0200
Message-ID: <2869131.K5Z6hvSGBl@blindfold>
References: <20171016181856.12497-1-richard@nod.at> <2297422.9nBBslcvMo@blindfold> <59E50473.7040609@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ast@kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59E50473.7040609@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 16. Oktober 2017, 21:11:47 CEST schrieb Daniel Borkmann: 
> > I can squash it into 1/3, I kept it that way because
> > even without 1/3 this variable is unused.
> 
> Hmm, the helper looks like the below. In patch 1/3 you removed
> the 'if (unlikely(!task))' test where the variable was used before,
> so 2/3 without the 1/3 would result in a compile error.

Why a compile error? It emits a warning.

> BPF_CALL_0(bpf_get_current_uid_gid)
> {
> 	struct task_struct *task = current;
> 	kuid_t uid;
> 	kgid_t gid;
> 
> 	if (unlikely(!task))
> 		return -EINVAL;

Well, this is the only "user". Okay.

> 	current_uid_gid(&uid, &gid);

Here we use current. So, task was always in vain.

So, I can happily squash 2/3 into 1/3 and resent.
The series just represented the way I've worked on the code... 

Thanks,
//richard
