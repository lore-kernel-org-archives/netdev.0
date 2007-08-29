From: Moni Shoua <monisonlists@gmail.com>
Subject: Re: [ofa-general] Re: [PATCH V4 10/10] net/bonding: Destroy bonding
	master when last slave is gone
Date: Wed, 29 Aug 2007 17:06:21 +0300
Message-ID: <46D57D5D.3060706@gmail.com>
References: <46C9B474.5020202@voltaire.com> <46C9BA2D.7060204@voltaire.com>
	<3403.1188343986@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, davem@davemloft.net, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <3403.1188343986@death>
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

Jay Vosburgh wrote:
> Moni Shoua <monis@voltaire.com> wrote:
> 
>> When bonding enslaves non Ethernet devices it takes pointers to functions 
>> in the module that owns the slaves. In this case it becomes unsafe
>> to keep the bonding master registered after last slave was unenslaved 
>> because we don't know if the pointers are still valid.  Destroying the bond when slave_cnt is zero
>> ensures that these functions be used anymore.
> 
> 	Would it not be simpler to run the bonding master through
> ether_setup() again when the final slave is released (to reset all of
> the pointers to their "ethernet" values)?  I'm presuming here the
> pointers of questionable validity are the ones set in the
> bond_setup_by_slave() copied from the slave_dev->hard_header, et al.
> 
> 	Having the bonding master disappear (but only sometimes) after
> the last slave is removed is a semantic change I'd rather not introduce
> if it's not necessary.

Thanks for the comments.

Having the master disappear is one way I could think of to solve the problem of leaving
the bonding module with pointers to illegal addresses.
The other way is to increase the usage count, with try_module_get(), of the module which owns of the slave.
To do that I  have to restore the field  owner in structure net_device (it was removed in 2.6).
Do you prefer the second approach? I wasn't sure about that.
