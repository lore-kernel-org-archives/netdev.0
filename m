From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3 1/3] init / kthread: add module_long_probe_init() and
	module_long_probe_exit()
Date: Mon, 18 Aug 2014 14:22:17 +0200
Message-ID: <20140818122217.GA12707@redhat.com>
References: <20140814231028.GQ21930@wotan.suse.de> <20140815143902.GB13222@redhat.com> <20140816025007.GB3347@wotan.suse.de> <s5h1tsfwqi2.wl-tiwai@suse.de> <20140817122527.GA30546@redhat.com> <20140817124803.GA31996@redhat.com> <20140817125505.GA32429@redhat.com> <20140817174624.GE3347@wotan.suse.de> <20140817182138.GA4411@redhat.com> <s5hfvguw570.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@suse.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Benjamin Poirier <bpoirier@suse.de>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: Takashi Iwai <tiwai@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750762AbaHRMZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 08:25:30 -0400
Content-Disposition: inline
In-Reply-To: <s5hfvguw570.wl-tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18, Takashi Iwai wrote:
>
> #define module_long_probe_init(initfn)				\
> 	static int _long_probe_##initfn(void *arg)		\
> 	{							\
> 		module_put_and_exit(initfn());			\
> 		return 0;					\
> 	}							\
> 	static int __init __long_probe_##initfn(void)		\
> 	{							\
> 		struct task_struct *__init_thread =		\
> 			kthread_create(_long_probe_##initfn,	\
> 				       NULL, #initfn);		\
> 		if (IS_ERR(__init_thread))			\
> 			return PTR_ERR(__init_thread);		\
> 		__module_get(THIS_MODULE);			\
> 		wake_up_process(__init_thread);			\
> 		return 0;					\
> 	}							\
> 	module_init(__long_probe_##initfn)
>
> ... and module_exit() remains identical as the normal version.

Aaaah. This is not true, module_exit() should not call exitfn() if initfn()
fails... So _long_probe_##initfn() needs to save the error code which should
be checked by module_exit().

> But, it's really a small difference, and I don't mind much which way
> to take, too.

Agreed.

Oleg.
