From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [linux-nfc] [PATCH 3/8] NFC: NCI: Adds NCI init and reset API
 for drivers
Date: Sun, 24 May 2015 19:07:58 +0200
Message-ID: <20150524170758.GC15886@ribalta.ccr.corp.intel.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
 <1424772112-27399-4-git-send-email-robert.dolca@intel.com>
 <20150326002937.GB10954@ribalta.home>
 <CAFPB+YcvZReLRsv5dYh=jTwASa1vo-0pK5T1AS-eGmzO=arDLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Dolca <robert.dolca@intel.com>, linux-nfc@lists.01.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Robert Dolca <robert.dolca@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAFPB+YcvZReLRsv5dYh=jTwASa1vo-0pK5T1AS-eGmzO=arDLQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Robert,

On Tue, Mar 31, 2015 at 05:05:53PM +0300, Robert Dolca wrote:
> On Thu, Mar 26, 2015 at 2:29 AM, Samuel Ortiz <sameo@linux.intel.com> wrote:
> > Hi Robert,
> >
> > On Tue, Feb 24, 2015 at 12:01:47PM +0200, Robert Dolca wrote:
> >> In order to communicate with the device during the setup
> >> phase, the driver may need to initialize the device. After
> >> the setup is done the driver should reset the device to leave
> >> it in the same state that it was before the setup function
> >> call.
> > I would prefer not to export those symbols, but instead introduce a
> > quirk bitmap to let the NCI core know that your device expects the core
> > to be initialized before calling the setup ops.
> > That would be done from nci_open_device().
> 
> As part of the initialization / firmware upgrade procedure the driver
> needs to reset and initialize the NCI connection multiple times.
> Having the connection initialized before calling setup is not enough.
Fair enough, I am ok with exporting those symbols.

BTW after looking at your setup routine, I think this is wrong:

+	/* Load firmware from disk */
+	r = fdp_nci_request_firmware(ndev);
+	if (r)
+		goto error;

You should be able to boot your NFC chipset without a local
patch. If there is one, then you can try patching your device, but
otherwise we should continue with the exisiting one.

Cheers,
Samuel.
