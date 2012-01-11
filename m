From: "Naveen B N (nbn)" <nbn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: CPU usage for IPSec in Linux 2.6.38
Date: Wed, 11 Jan 2012 12:39:07 +0530
Message-ID: <A2354B6A9F807641B21EEABD666ECEEA02596EEE@XMB-BGL-416.cisco.com>
References: <A2354B6A9F807641B21EEABD666ECEEA02596D98@XMB-BGL-416.cisco.com><1326209072.19095.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC><A2354B6A9F807641B21EEABD666ECEEA02596E0B@XMB-BGL-416.cisco.com>
	<20120110.223439.142967999090229499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <ipsec-tools-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <20120110.223439.142967999090229499.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel>,
	<mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipsec-tools-devel>
List-Post: <mailto:ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipsec-tools-devel>,
	<mailto:ipsec-tools-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: ipsec-tools-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,
Thanks for the early reply .

I can't have a wild card has my outer IP address
Are unique for across Ipsec Tunnle > 6000, so 
I this case I have to add all the policies for 
Which the selectors my have a wild card but 
Outer IP address are specific and unique.

So taught of optimizing my just adding the policy 
Entry without the actual checking the previous list 
In kernel.

Is there better way of doing it David.

Thanks and Regards
Naveen

-----Original Message-----
From: David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org] 
Sent: Wednesday, January 11, 2012 12:05 PM
To: Naveen B N (nbn)
Cc: ipsec-tools-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Subject: Re: CPU usage for IPSec in Linux 2.6.38

From: "Naveen B N (nbn)" <nbn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Date: Wed, 11 Jan 2012 08:20:12 +0530

> Did anybody try creating IPSec Tunnels > 6000 in Linux
> And faced the same problem below.

The problem is that you must situate your rules according to
certain rules otherwise performance will suffer greatly.

You must:

1) Predominantly use fully specified, non-wildcard, rules.

   These go into a special hash table which approaches complexity
   O(1).

2) If you absolutely must have wildcarded rules, only have an
   extremely small number of them.

   These go onto a linked list which is O(N).

There is no reasonable reason to have thousands of wildcarded
rules.

Thousands of fully specified non-wildcard rules are reasonable,
and what we optimize the IPSEC datastructures for.

------------------------------------------------------------------------------
Ridiculously easy VDI. With Citrix VDI-in-a-Box, you don't need a complex
infrastructure or vast IT resources to deliver seamless, secure access to
virtual desktops. With this all-in-one solution, easily deploy virtual 
desktops for less than the cost of PCs and save 60% on VDI infrastructure 
costs. Try it free! http://p.sf.net/sfu/Citrix-VDIinabox
