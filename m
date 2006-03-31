From: "Jeff V. Merkey" <jmerkey@wolfmountaingroup.com>
Subject: Re: [PATCH]: e1000: prevent statistics from getting garbled during
	reset.
Date: Fri, 31 Mar 2006 11:40:16 -0700
Message-ID: <442D7790.2010300@wolfmountaingroup.com>
References: <20060330213928.GQ2172@austin.ibm.com>
	<20060331000208.GS2172@austin.ibm.com>
	<442C8069.507@wolfmountaingroup.com>
	<20060331003506.GU2172@austin.ibm.com>
	<442CACC0.1060308@wolfmountaingroup.com>
	<20060331170319.GV2172@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, linuxppc-dev@ozlabs.org,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com,
	linux-pci@atrey.karlin.mff.cuni.cz, Jeff Garzik <jgarzik@pobox.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060331170319.GV2172@austin.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:

>On Thu, Mar 30, 2006 at 09:14:56PM -0700, Jeffrey V. Merkey wrote:
>  
>
>>Yes, we need one. The adapter needs to maintain these stats from the
>>registers in the kernel structure and not
>>its own local variables. 
>>    
>>
>
>Did you read the code to see what the adapter does with these stats? 
>Among other things, it uses them to adaptively modulate transmit rates 
>to avoid collisions. Just clearing the hardware-private stats will mess
>up that function.
>
>  
>
I noticed that.

>>That way, when someone calls to clear the stats
>>for testing and analysis purposes,
>>they zero out and are reset.
>>    
>>
>
>1) ifdown/ifup is guarenteed to to clear things. Try that.
>  
>
No, not dynamic. I'll patch the driver locally, thanks.

Jeff

>2) What's wrong with taking deltas? Typical through-put performance
>measurement is done by pre-loading the pipes (i.e. running for
>a few minutes wihtout measuring, then starting the measurement).
>I'd think that snapshotting the numbers would be easier, and is 
>trivially doable in user-space. I guess I don't understand why 
>you need a new kernel featre to imlement this.
>
>--linas
>
>  
>
