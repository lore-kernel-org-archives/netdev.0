From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC v2 2/6] driver-core: add driver async_probe support
Date: Fri, 5 Sep 2014 13:24:17 +0200
Message-ID: <20140905112417.GB22778@redhat.com>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com> <1409899047-13045-3-git-send-email-mcgrof@do-not-panic.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:27568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756478AbaIEL12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 07:27:28 -0400
Content-Disposition: inline
In-Reply-To: <1409899047-13045-3-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04, Luis R. Rodriguez wrote:
>
>  struct driver_private {
>  	struct kobject kobj;
>  	struct klist klist_devices;
>  	struct klist_node knode_bus;
>  	struct module_kobject *mkobj;
> +	struct driver_attach_work *attach_work;
>  	struct device_driver *driver;

I am not arguing, just curious...

Are you trying to shrink sizeof(driver_private) ? The code can be simpler
if you just embedd "struct work_struct attach_work" into driver_private,
and you do not need "struct driver_attach_work" or another ->driver pointer
this way.

Oleg.
