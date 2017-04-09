From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH 1/5] netlink: extended ACK reporting
Date: Sun, 9 Apr 2017 13:43:26 -0400
Message-ID: <990b5610-a894-b3d2-d3a7-536dfd25adb8@cumulusnetworks.com>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
 <20170408174900.12820-2-johannes@sipsolutions.net>
 <20170408183440.GA1900@nanopsycho>
 <1491676621.5800.24.camel@sipsolutions.net>
 <20170408184008.GB1900@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
        Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170408184008.GB1900@nanopsycho>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/8/17 2:40 PM, Jiri Pirko wrote:
> Sat, Apr 08, 2017 at 08:37:01PM CEST, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org wrote:
>> On Sat, 2017-04-08 at 20:34 +0200, Jiri Pirko wrote:
>>> nla_total_size(sizeof(u32));
>>>> +			if (extack &&
>>>> +			    (extack->missing_attr || extack-
>>>>> bad_attr))
>>>
>>> Attr could be 0, right? I know that on the most of the places 0 is
>>> UNSPEC, but I'm pretty sure not everywhere.

perhaps I misunderstand something, but nla_parse suggests attribute type
can not be 0:

int nla_parse(struct nlattr **tb, int maxtype, const struct nlattr *head,
              int len, const struct nla_policy *policy,
              struct netlink_ext_ack *extack)
{
	...

        nla_for_each_attr(nla, head, len, rem) {
                u16 type = nla_type(nla);

                if (type > 0 && type <= maxtype) {
			...
                        tb[type] = (struct nlattr *)nla;
                }
        }


> Also, could you please attach a patch to iproute2 for example which
> would make use of this. I just want to make sure it clicks.

I have follow on patches to Johannes' set that plumbs extack for
rtnetlink doit function and iproute2. will send later.
