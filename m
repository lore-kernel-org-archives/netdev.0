From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] x86: Run checksumming in parallel accross multiple alu's
Date: Wed, 30 Oct 2013 12:18:06 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73C5@saturn3.aculab.com>
References: <201310300525.r9U5Pdqo014902@ib.usersys.redhat.com> <20131030110214.GA10220@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Ingo Molnar" <mingo@kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Neil Horman" <nhorman@tuxdriver.com>,
	"Doug Ledford" <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20131030110214.GA10220@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> /me wonders if rearranging the instructions into this order:
> adcq 0*8(src), res1
> adcq 1*8(src), res2
> adcq 2*8(src), res1

Those have to be sequenced.

Using a 64bit lea to add 32bit quantities should avoid the
dependencies on the flags register.
However you'd need to get 3 of those active to beat a 64bit adc.

	David
