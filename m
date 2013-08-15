From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] net: sync some IP headers with glibc
Date: Thu, 15 Aug 2013 16:42:43 +0800
Message-ID: <1376556163.2626.11.camel@cr0>
References: <1376383054-9184-1-git-send-email-amwang@redhat.com>
	 <20130814.134246.1152657041177088716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tmb@mageia.org, libc-alpha@sourceware.org,
        yoshfuji@linux-ipv6.org, carlos@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <libc-alpha-return-41954-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-##L=##H@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <20130814.134246.1152657041177088716.davem@davemloft.net>
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-14 at 13:42 -0700, David Miller wrote:
> > -#define IPPROTO_HOPOPTS              0       /* IPv6 hop-by-hop
> options      */
> > -#define IPPROTO_ROUTING              43      /* IPv6 routing
> header          */
> > -#define IPPROTO_FRAGMENT     44      /* IPv6 fragmentation
> header    */
> > -#define IPPROTO_ICMPV6               58      /*
> ICMPv6                       */
> > -#define IPPROTO_NONE         59      /* IPv6 no next
> header          */
> > -#define IPPROTO_DSTOPTS              60      /* IPv6 destination
> options     */
> > -#define IPPROTO_MH           135     /* IPv6 mobility
> header         */
> > +#if __UAPI_DEF_IPPROTO_V6
> > +enum {
> > +  IPPROTO_HOPOPTS = 0,               /* IPv6 hop-by-hop options
> */
> 
> Again, do not reformat things, it's an unrelated change and makes
> this patch harder to review. 

Hmm, for this one, the original format is hard to keep since this patch
changes macros to enum's. What this patch does here looks correct to me,
for reference, below is the original code:

#define IPPROTO_HOPOPTS         0       /* IPv6 hop-by-hop options
*/
#define IPPROTO_ROUTING         43      /* IPv6 routing header
*/
#define IPPROTO_FRAGMENT        44      /* IPv6 fragmentation header
*/
#define IPPROTO_ICMPV6          58      /* ICMPv6
*/
#define IPPROTO_NONE            59      /* IPv6 no next header
*/
#define IPPROTO_DSTOPTS         60      /* IPv6 destination options
*/
#define IPPROTO_MH              135     /* IPv6 mobility header
*/

and here is the code after patch:

#if __UAPI_DEF_IPPROTO_V6
enum {
  IPPROTO_HOPOPTS = 0,          /* IPv6 hop-by-hop options      */
#define IPPROTO_HOPOPTS         IPPROTO_HOPOPTS
  IPPROTO_ROUTING = 43,         /* IPv6 routing header          */
#define IPPROTO_ROUTING         IPPROTO_ROUTING
  IPPROTO_FRAGMENT = 44,        /* IPv6 fragmentation header    */
#define IPPROTO_FRAGMENT        IPPROTO_FRAGMENT
  IPPROTO_ICMPV6 = 58,          /* ICMPv6                       */
#define IPPROTO_ICMPV6          IPPROTO_ICMPV6
  IPPROTO_NONE = 59,            /* IPv6 no next header          */
#define IPPROTO_NONE            IPPROTO_NONE
  IPPROTO_DSTOPTS = 60,         /* IPv6 destination options     */
#define IPPROTO_DSTOPTS         IPPROTO_DSTOPTS
  IPPROTO_MH = 135,             /* IPv6 mobility header         */
#define IPPROTO_MH              IPPROTO_MH
};
#endif /* __UAPI_DEF_IPPROTO_V6 */


Or I don't get your point?

Thanks.
