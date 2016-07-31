From: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Subject: RE: [PATCH v5 6/8] thunderbolt: Networking transmit and receive
Date: Sun, 31 Jul 2016 10:15:52 +0000
Message-ID: <E607265CB020454880711A6F96C05A039710868B@hasmsx108.ger.corp.intel.com>
References: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
	<1469693721-5641-7-git-send-email-amir.jer.levy@intel.com>
 <20160729140741.18ca3e35@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "andreas.noever@gmail.com" <andreas.noever@gmail.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"bhelgaas@google.com" <bhelgaas@google.com>,
	"corbet@lwn.net" <corbet@lwn.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	thunderbolt-linux <thunderbolt-linux@intel.com>,
	"Westerberg, Mika" <mika.westerberg@intel.com>,
	"Winkler, Tomas" <tomas.winkler@intel.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20160729140741.18ca3e35@xeon-e3>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 30 2016, 12:07 AM, Stephen Hemminger wrote:
> On Thu, 28 Jul 2016 11:15:19 +0300
> Amir Levy <amir.jer.levy@intel.com> wrote:
> 
> > +		/* pad short packets */
> > +		if (unlikely(skb->len < ETH_ZLEN)) {
> > +			int pad_len = ETH_ZLEN - skb->len;
> > +
> > +			/* The skb is freed on error */
> > +			if (unlikely(skb_pad(skb, pad_len))) {
> > +				cleaned_count += frame_count;
> > +				continue;
> > +			}
> > +			__skb_put(skb, pad_len);
> > +		}
> 
> Packets should be padded on transmit, not on receive??

This driver emulates an Ethernet adapter on top of Thunderbolt technology.
The Thunderbolt medium hasn't any restriction on minimum frame size and doesn't have the Ethernet collision detection limitation.
So moving this code from transmit is actually an optimization - sending the minimum on the wire.
The network stack thinks it is Ethernet, it might not accept Runt frames, so the driver pads the frame in receive.

Looks like it deserves a comment in the code. Will add it.
