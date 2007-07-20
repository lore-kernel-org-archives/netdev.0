From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ofa-general] Re: [PATCH 00/10] Implement batching skb API
Date: Fri, 20 Jul 2007 08:57:37 +0100
Message-ID: <20070720085737.5319d3d4@oldman>
References: <20070720081848.7cc652fb@oldman>
	<OF37602E5B.BA36F154-ON6525731E.0028A4E9-6525731E.00293CC3@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	sri@us.ibm.com, davem@davemloft.net, rdreier@cisco.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <OF37602E5B.BA36F154-ON6525731E.0028A4E9-6525731E.00293CC3@in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Jul 2007 13:00:25 +0530
Krishna Kumar2 <krkumar2@in.ibm.com> wrote:

> Stephen Hemminger <shemminger@linux-foundation.org> wrote on 07/20/2007
> 12:48:48 PM:
> 
> > You may see worse performance with batching in the real world when
> > running over WAN's.  Like TSO, batching will generate back to back packet
> > trains that are subject to multi-packet synchronized loss. The problem is
> that
> > intermediate router queues are often close to full, and when a long
> string
> > of packets arrives back to back only the first ones will get in, the rest
> > get dropped.  Normal sends have at least minimal pacing so they are less
> > likely do get synchronized drop.
> 
> Hi Stephen,
> 
> OK. The difference that I could see is that in existing code, the "minimal
> pacing" also could lead to (possibly slighly lesser) loss since sends are
> quick iterations at the IP layer, while in batching sends are iterative at
> the driver layer.
> 
> Is it an issue ? Any suggestions ?

Not an immediate issue, but it is the kind of thing that could cause performance
regression reports if it was used on every interface by default.
