From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Fri, 5 Sep 2014 12:59:49 +0200
Message-ID: <20140905105949.GA22778@redhat.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com> <1409899047-13045-4-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	falcon@meizu.com, tiwai@suse.de, tj@kernel.org,
	arjan@linux.intel.com, linux-kernel@vger.kernel.org, hare@suse.com,
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
	netdev@vger.
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17518 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756472AbaIELDO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 07:03:14 -0400
Content-Disposition: inline
In-Reply-To: <1409899047-13045-4-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04, Luis R. Rodriguez wrote:
>
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>
> The new umh kill option has allowed kthreads to receive
> kill signals but they are generally accepting all sources
> of kill signals

And I think this is right,

> while the original motivation was to enable
> through the OOM from sending the kill.

even if the main concern was OOM.

> Users can provide a log output and it should be clear on
> the trace what probe / driver got the kill signal.

Well, if you need a WARN output, perhaps you could just add
WARN_ON(fatal_signal_pending()) at the end of load_module() ?

Not only kthread_create() can fail if systemd sends SIGKILL.

> Although Oleg had rejected a
> similar change a while ago

And honestly, I still dislike this change.

Oleg.
