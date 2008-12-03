From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 07/39] wimax: generic WiMAX device management
	(registration, deregistration, etc)
Date: Tue, 2 Dec 2008 18:06:36 -0800
Message-ID: <200812021806.36819.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com>
	<8b18de7322859679eefc5e9f1a86249d41762140.1227691434.git.inaky@linux.intel.com>
	<492E793A.7020501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <492E793A.7020501@trash.net>
Content-Disposition: inline
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

On Thursday 27 November 2008, Patrick McHardy wrote:
> Inaky Perez-Gonzalez wrote:
> > +static
> > +struct nla_policy wimax_gnl_result_policy[WIMAX_GNL_ATTR_MAX + 1] = {
>
> const please for all policies.

Done.

> > +int wimax_gnl_send_rp_result(struct wimax_dev *wimax_dev,
> > +			     struct genl_info *genl_info,
> > +			     ssize_t code)
> > +{
> > +	int result;
> > +	struct device *dev = wimax_dev_to_dev(wimax_dev);
> > +	void *data;
> > +	struct sk_buff *reply_skb;
> > +	s64 code_s64 = code;
> > +
> > +	d_fnstart(3, dev, "(wimax_dev %p info %p code %zd)\n",
> > +		  wimax_dev, genl_info, code);
> > +	result = -ENOMEM;
> > +	reply_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> > +	if (reply_skb == NULL)
> > +		goto error_new;
> > +	data = genlmsg_put_reply(reply_skb, genl_info,
> > +				 &wimax_dev->gnl_family,
> > +				 0, WIMAX_GNL_RP_RESULT);
> > +	if (data == NULL)
> > +		goto error_put_reply;
> > +
> > +	result = nla_put_u64(reply_skb, WIMAX_GNL_RESULT_CODE, (u64) code_s64);
> > +	if (result < 0)
> > +		dev_err(dev, "Error putting attribute: %d\n", result);
>
> This is not how netlink protocols should treat errors.
> It should return -ENOSPC (everywhere else also of course).

Other than the fact that this function is gone after Johannes comments
(so for everywhere else), wouldn't returning the -EMSGSIZE nla_put_*() 
returns enough?

I changed all of them to be something like:

result = nla_put*();
if (result < 0)
	goto error path /* release skb/msg, return result */

Thanks,

-- 
Inaky
