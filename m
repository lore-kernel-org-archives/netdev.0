From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Network device driver probe issues
Date: Fri, 16 Jul 2004 15:52:58 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40F8321A.7000404@pobox.com>
References: <468F3FDA28AA87429AD807992E22D07E01CEF1BF@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jim Keniston <jkenisto@us.ibm.com>, David Dillow <dave@thedillows.org>,
        Anton Blanchard <anton@samba.org>, Netdev <netdev@oss.sgi.com>,
        cramerj <cramerj@intel.com>, "Ronciak, John" <john.ronciak@intel.com>,
        jonmason@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E01CEF1BF@orsmsx408>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Venkatesan, Ganesh wrote:
> We've fixed the e100 to have the same logic as e1000. I like the typhoon
> driver idea.


Unfortunately both are wrong.

e1000 should not be using dev_alloc_name(), and patches to add that to 
e100 will not be accepted.

e100 should not be referencing netdev->name until after 
register_netdev() completes.

The typhoon solution is fine with me.  Other drivers don't bother and 
simply use pci_name() during probe.  It's up to you as maintainer.

	Jeff
