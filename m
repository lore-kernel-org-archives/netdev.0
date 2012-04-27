From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] e1000e:  MSI interrupt test failed,
 using legacy interrupt
Date: Fri, 27 Apr 2012 02:40:40 +0100
Message-ID: <1335490840.4056.137.camel@deadeye>
References: <1335485150-2765-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	e1000-devel@lists.sourceforge.net, gospo@redhat.com, sassmann@redhat.com
To: <prasanna.panchamukhi@riverbed.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1335485150-2765-1-git-send-email-prasanna.panchamukhi@riverbed.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 2012-04-26 at 17:05 -0700, prasanna.panchamukhi@riverbed.com
wrote:
> From: Prasanna S. Panchamukhi <ppanchamukhi@riverbed.com>
> 
> Following logs where seen on Systems with multiple NICs & ports,
> while using MSI interrupts as shown below:
[...]
> This patch changes the IRQ tests to use polling loops starting with a
> delay of 1 tick and doubling that if necessary up to a maximum total
> delay of approximately 1 second.
[...]

I don't think you entirely understood my point.  This exponential
back-off was the best I could come up with for a self-test
(ethtool -t) where we have to answer the question 'are interrupts
working' in a reasonable time, and the user can decide for themselves
whether this was a false negative.

If you want a definite answer in order to make an automatic decision
about interrupt modes, there really is no valid time limit.  I think the
proper way to do interrupt mode selection in an in-tree driver is to
rely on no-MSI quirks for chipsets and devices in the PCI core.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
