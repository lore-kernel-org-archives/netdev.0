From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: TG3, kvm, ipv6 & tso data corruption bug?
Date: Wed, 28 Oct 2009 09:32:26 -0700
Message-ID: <20091028163226.GA8556@xw6200.broadcom.net>
References: <4AE8595F.1080404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Linux kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"KVM list" <kvm@vger.kernel.org>
To: "Rik van Riel" <riel@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4AE8595F.1080404@redhat.com>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28, 2009 at 07:46:55AM -0700, Rik van Riel wrote:
> I have been tracking down what I thought was a KVM related network
> issue for a while, however it appears it could be a hardware issue.
> 
> The symptom is that data in network packets gets corrupted, before
> the checksum is calculated.  This means the remote host can get
> corrupted data, with no way to calculate it (except application
> level checksums).  Luckily ssh has such checksums, so my rsync over
> ssh backup script discovered this issue.
> 
> On a very regular basis, I got this message from ssh:
> 
> 	Corrupted MAC on input.
> 
> I have played around a bit and narrowed it down to the following:
> 
> ipv4          => no problem
> ipv6 w/o tso  => no problem
> ipv6 with tso => occasional data corruption
> 
> Disabling tso with ethtool -K eth0 tso off makes the problem stop.
> 
> I am running Fedora 12's 2.6.31.1-56.fc12.x86_64 kernel, with the
> following hardware:
> 
> 05:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5761 
> Gigabit Ethernet PCIe (rev 10)
> 
> I do not know enough about the network layer to know whether this is
> fixable in software or whether TSO offloading for ipv6 should just
> be disabled on this model.

This problem sounds familiar.  There are chip bugs in this area, but as
far as I know, they should have been worked around.  Let me see if this
is indeed the same bug resurfacing.

