From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Fri, 5 Sep 2014 16:19:25 +0900
Message-ID: <20140905071925.GC9323@mtj.dyndns.org>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <1409899047-13045-4-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	falcon@meizu.com, tiwai@suse.de, arjan@linux.intel.com,
	linux-kernel@vger.kernel.org, oleg@redhat.com, hare@suse.com,
	akpm@linux-foundation.org, penguin-kernel@i-love.sakura.ne.jp,
	joseph.salisbury@canonical.com, bpoirier@suse.de,
	santosh@chelsio.com, "Luis R. Rodriguez" <mcgrof@suse.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Casey Leedom <leedom@chelsio.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vge
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1409899047-13045-4-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 04, 2014 at 11:37:24PM -0700, Luis R. Rodriguez wrote:
...
> +		/*
> +		 * I got SIGKILL, but wait for 60 more seconds for completion
> +		 * unless chosen by the OOM killer. This delay is there as a
> +		 * workaround for boot failure caused by SIGKILL upon device
> +		 * driver initialization timeout.
> +		 *
> +		 * N.B. this will actually let the thread complete regularly,
> +		 * wait_for_completion() will be used eventually, the 60 second
> +		 * try here is just to check for the OOM over that time.
> +		 */
> +		WARN_ONCE(!test_thread_flag(TIF_MEMDIE),
> +			  "Got SIGKILL but not from OOM, if this issue is on probe use .driver.async_probe\n");
> +		for (i = 0; i < 60 && !test_thread_flag(TIF_MEMDIE); i++)
> +			if (wait_for_completion_timeout(&done, HZ))
> +				goto wait_done;
> +

Ugh... Jesus, this is way too hacky, so now we fail on 90s timeout
instead of 30?  Why do we even need this with the proposed async
probing changes?

Thanks.

-- 
tejun
