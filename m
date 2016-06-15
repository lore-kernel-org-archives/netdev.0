From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [very-RFC 7/8] AVB ALSA - Add ALSA shim for TSN
Date: Wed, 15 Jun 2016 13:49:08 +0200
Message-ID: <20160615114908.GB31281@localhost.localdomain>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <1465686096-22156-8-git-send-email-henrik@austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	alsa-devel@vger.kernel.org, netdev@vger.kernel.org,
	henrk@austad.us, Henrik Austad <haustad@cisco.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
	Takashi Iwai <tiwai@suse.de>, Mark Brown <broonie@kernel.org>
To: Henrik Austad <henrik@austad.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465686096-22156-8-git-send-email-henrik@austad.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that I understand better...

On Sun, Jun 12, 2016 at 01:01:35AM +0200, Henrik Austad wrote:
> Userspace is supposed to reserve bandwidth, find StreamID etc.
> 
> To use as a Talker:
> 
> mkdir /config/tsn/test/eth0/talker
> cd /config/tsn/test/eth0/talker
> echo 65535 > buffer_size
> echo 08:00:27:08:9f:c3 > remote_mac
> echo 42 > stream_id
> echo alsa > enabled

This is exactly why configfs is the wrong interface.  If you implement
the AVB device in alsa-lib user space, then you can handle the
reservations, configuration, UDP sockets, etc, in a way transparent to
the aplay program.

Heck, if done properly, your layer could discover the AVB nodes in the
network and present each one as a separate device...

Thanks,
Richard
