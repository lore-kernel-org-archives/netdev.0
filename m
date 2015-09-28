From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] net: sctp: Don't use 64 kilobyte lookup table for
 four elements
Date: Mon, 28 Sep 2015 14:12:26 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBA41B0@AcuExch.aculab.com>
References: <1443443644-12825-1-git-send-email-dvlasenk@redhat.com>
 <20150928135127.GB5248@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Neil Horman' <nhorman@tuxdriver.com>,
	Denys Vlasenko <dvlasenk@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150928135127.GB5248@hmsreliant.think-freely.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman
> Sent: 28 September 2015 14:51
> On Mon, Sep 28, 2015 at 02:34:04PM +0200, Denys Vlasenko wrote:
> > Seemingly innocuous sctp_trans_state_to_prio_map[] array
> > is way bigger than it looks, since
> > "[SCTP_UNKNOWN] = 2" expands into "[0xffff] = 2" !
> >
> > This patch replaces it with switch() statement.

What about just adding 1 (and masking) before indexing the array?
That might require a static inline function with a local static array.

Or define the array as (say) [16] and just mask the state before using
it as an index?

	David
