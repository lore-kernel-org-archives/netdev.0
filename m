From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Looking for extensible kernel database format
Date: Thu, 9 Apr 2015 17:57:44 -0700
Message-ID: <CAB=NE6W4Q2ngB6CF8pG=OV6=q+9CTcwA6UGhdgS+OCT++N2GJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Kees Cook <kees@outflux.net>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Seth Forshee <seth.forshee@canonical.com>,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	netfilter-devel@vger.kernel.org
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey folks,

next week I'd like to address replacing the need for CRDA [0] as a
udev helper with in-kernel functionality  There's a few motivations
for this but a good one is that the kernel already has now
cryptographic support to verify the integrity of the regulatory
database, just as it has support for verifying the integrity of
modules / firmware. We'd use something like:

request_file(file_reqs)

Where the file_reqs provides the requirements, including cryptographic
requirements, and I suspect we'd use LSM to vet for the cryptographic
needs of the file.

Now other than this step CRDA currently *reads* a database and today
we have our own format. If we want to extend this though we will have
to issue a new regdb format and old kernels might not be compatible
with the new format. This is a typical database problem and I'm hoping
we are not the first to deal with this. What *extensible* kernel
database format are there already, are they generic already? I'd
prefer something already using netlink.

Any recommendations?

[0] https://wireless.wiki.kernel.org/en/developers/regulatory/crda

  Luis
