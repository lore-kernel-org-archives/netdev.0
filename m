From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: sctp: Don't use 64 kilobyte lookup table for
 four elements
Date: Mon, 28 Sep 2015 07:27:07 -0700
Message-ID: <1443450427.2531.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443443644-12825-1-git-send-email-dvlasenk@redhat.com>
	 <20150928135127.GB5248@hmsreliant.think-freely.org>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBA41B0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Neil Horman' <nhorman@tuxdriver.com>,
	Denys Vlasenko <dvlasenk@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBA41B0@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-09-28 at 14:12 +0000, David Laight wrote:
> From: Neil Horman
> > Sent: 28 September 2015 14:51
> > On Mon, Sep 28, 2015 at 02:34:04PM +0200, Denys Vlasenko wrote:
> > > Seemingly innocuous sctp_trans_state_to_prio_map[] array
> > > is way bigger than it looks, since
> > > "[SCTP_UNKNOWN] = 2" expands into "[0xffff] = 2" !
> > >
> > > This patch replaces it with switch() statement.
> 
> What about just adding 1 (and masking) before indexing the array?
> That might require a static inline function with a local static array.
> 
> Or define the array as (say) [16] and just mask the state before using
> it as an index?

Just let the compiler do its job, instead of obfuscating source.

Compilers can transform a switch into an (optimal) table if it is really
a gain.
