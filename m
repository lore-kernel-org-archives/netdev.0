From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH 2/3] cxgb4: make configuration load use
	request_firmware_direct()
Date: Wed, 25 Jun 2014 22:05:10 +0200
Message-ID: <20140625200510.GY27687@wotan.suse.de>
References: <1403649583-12707-1-git-send-email-mcgrof@do-not-panic.com> <1403649583-12707-3-git-send-email-mcgrof@do-not-panic.com> <D46B557B-AF4A-4E60-8D83-6181D406C64F@chelsio.com> <20140625015048.GI27687@wotan.suse.de> <53AB02F4.1090701@chelsio.com> <20140625173156.GW27687@wotan.suse.de> <53AB1BEC.4080107@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, tiwai@suse.de,
	chunkeey@googlemail.com, cocci@systeme.lip6.fr,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, Philip Oswald <poswald@suse.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Jeffrey Cheung <jcheung@suse.com>,
	David Chang <dchang@suse.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53AB1BEC.4080107@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 25, 2014 at 11:58:52AM -0700, Casey Leedom wrote:
>   Okay, I'll leave the whole request_firmware{,_direct,_nowait}() thing 
> alone.  The request_firmware_direct() will "solve" a non-problem (since all 
> of our "firmware" files are _supposed to be_ always present.

The code does not reflect that, it allows for files to not be present for
the config stuff. If in practice files are always present that's a bit
different.

> (And the 60 
> second timeout for udev to confirm that a file doesn't exist seems like 
> udev is just basically broken.)

Its one reason it being tossed.

>   That aside, we still need to solve the real problem that we're 
> experiencing in that the boot-time load of cxgb4 is timing out on SLE12 
> because a maximum load timeout has been instituted in that distribution for 
> driver modules and if there are two 10Gb/s-BT adapters present in a system 
> which need both base firmware and BT PHY firmware, we exceed that timeout.  

As for that it'd be great if you can answer some questions I had about
the rest of firmware load processing on the other thread, I had a bit
of questions for you there.

> The timeout really should be per device (since there ~could~ be an 
> arbitrary number of devices in a system) and there probably should be a way 
> for the driver to notify the kernel timeout mechanism that forward progress 
> is being made ...

I'd prefer we dive into this on the other thread.

  Luis
