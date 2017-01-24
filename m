From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: Add a proper check for the availability of
 the checksum features
Date: Tue, 24 Jan 2017 15:15:33 -0500 (EST)
Message-ID: <20170124.151533.1564753892669791067.davem@davemloft.net>
References: <1485239321-14947-1-git-send-email-thuth@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
 linuxppc-dev@lists.ozlabs.org
To: thuth@redhat.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1485239321-14947-1-git-send-email-thuth@redhat.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

From: Thomas Huth <thuth@redhat.com>
Date: Tue, 24 Jan 2017 07:28:41 +0100

> When using the ibmveth driver in a KVM/QEMU based VM, it currently
> always prints out a scary error message like this when it is started:
> 
>  ibmveth 71000003 (unregistered net_device): unable to change
>  checksum offload settings. 1 rc=-2 ret_attr=71000003
> 
> This happens because the driver always tries to enable the checksum
> offloading without checking for the availability of this feature first.
> QEMU does not support checksum offloading for the spapr-vlan device,
> thus we always get the error message here.
> According to the LoPAPR specification, the "ibm,illan-options" property
> of the corresponding device tree node should be checked first to see
> whether the H_ILLAN_ATTRIUBTES hypercall and thus the checksum offloading
> feature is available. Thus let's do this in the ibmveth driver, too, so
> that the error message is really only limited to cases where something
> goes wrong, and does not occur if the feature is just missing.
> 
> Signed-off-by: Thomas Huth <thuth@redhat.com>

Applied.
