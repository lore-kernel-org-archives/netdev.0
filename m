From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] datapath: 16bit inner_network_header field in
	struct ovs_gso_cb
Date: Tue, 20 May 2014 17:14:25 -0700
Message-ID: <CAEP_g=_ri4kY+4aBZGjohZkrSJQkxHg7ybo+szFTiouY0AzZvA@mail.gmail.com>
References: <1400582464-2917-1-git-send-email-horms@verge.net.au>
 <CAEP_g=-1OfxGfRt58TtamGC955f7fG4z9tti3j0crYM73mJ2ug@mail.gmail.com>
 <20140520233145.GA30260@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140520233145.GA30260-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tue, May 20, 2014 at 4:31 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> On Tue, May 20, 2014 at 12:54:32PM -0700, Jesse Gross wrote:
>> On Tue, May 20, 2014 at 3:41 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
>> > diff --git a/datapath/linux/compat/gso.h b/datapath/linux/compat/gso.h
>> > index b83a4c3..f459c18 100644
>> > --- a/datapath/linux/compat/gso.h
>> > +++ b/datapath/linux/compat/gso.h
>> >  #ifdef NET_SKBUFF_DATA_USES_OFFSET
>> > -#define skb_inner_network_header rpl_skb_inner_network_header
>> > -static inline unsigned char *skb_inner_network_header(const struct sk_buff *skb)
>> > -{
>> > -       return skb->head + OVS_GSO_CB(skb)->inner_network_header;
>> > -}
>> > -
>> >  #define skb_inner_mac_header rpl_skb_inner_mac_header
>> >  static inline unsigned char *skb_inner_mac_header(const struct sk_buff *skb)
>> >  {
>> >         return skb->head + OVS_GSO_CB(skb)->inner_mac_header;
>> >  }
>> >
>> > +#define skb_inner_network_header rpl_skb_inner_network_header
>> > +static inline unsigned char *skb_inner_network_header(const struct sk_buff *skb)
>> > +{
>> > +       return skb_inner_mac_header(skb) +
>> > +               OVS_GSO_CB(skb)->inner_network_header;
>> > +}
>> > +
>> >  #else
>>
>> This looks mostly fine to me but doesn't this need to be outside the
>> #ifdef NET_SKBUFF_DATA_USES_OFFSET block? Otherwise we will treat the
>> offset as a pointer on 32 bit kernels.
>
> Thanks, Somehow I completely missed that.
> How about this?
>
>
> From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
>
> [PATCH v1.1] datapath: 16bit inner_network_header field in struct ovs_gso_cb
>
> The motivation for this is to create a 16bit hole in struct ovs_gso_cb
> which may be used for the inner_protocol field which is needed
> for the proposed implementation of compatibility for MPLS GSO segmentation.
>
> This should be safe as inner_network_header is now an offset to
> the inner_mac_header rather than skb->head.
>
> As pointed out by Thomas Graf simply making both inner offsets 16bis is not
> safe as there have been cases of overflow with "with collapsed TCP frames
> on IB when the headroom grew beyond 64K. See commit 50bceae9bd ``tcp:
> Reallocate headroom if it would overflow csum_start'' for additional
> details."
>
> This patch is based on suggestions by Thomas Graf and Jesse Gross.
>
> Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
> Cc: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

Applied, thanks.
