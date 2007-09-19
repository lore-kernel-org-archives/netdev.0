From: Moni Shoua <monis@voltaire.com>
Subject: Re: [ofa-general] Re: [PATCH 02/11] IB/ipoib: Notify the world before
	doing unregister
Date: Wed, 19 Sep 2007 19:41:57 +0300
Message-ID: <46F15155.4070708@voltaire.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>	<11898132322950-git-send-email-fubar@us.ibm.com>	<1189813234208-git-send-email-fubar@us.ibm.com>	<adatzptkjyk.fsf@cisco.com>
	<18593.1190071438@death>	<adaps0glve4.fsf@cisco.com>
	<ada3axblvj2.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	general@lists.openfabrics.org
To: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <ada3axblvj2.fsf@cisco.com>
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


Roland, Jay, 
Thanks a lot for the comments.
I'd like to summarize the points raised so far

1. Reduce the indentation in patch #4 (Roland)
	I will resend
2. Remove the "if (n->dev->flags & IFF_MASTER)" from patch #3 (Roland)
	I will resend
3. Consider making ipoib_slave_detach() net/core/dev.c (Roland, Jay)
	I think that this is a good idea. I can make the patch (and necessary changes to 
	the other patches) assuming this is agreed by all.
4. Change header for patch #1 (Roland)
	I will resend
5. Use NETDEV_GOING_DOWN and not NETDEV_CHANGE + IFF_SLAVE_DETACH (Jay)
	The  NETDEV_GOING_DOWN event is sent in the contex of unregister_netdevice() 
	Since the action in bonding to the event should be unregister the bonding master
	it is not possible to do so. bonding needs to know about the slave detach earlier.
6. call notifiers from unregister_netdev()
	See answer to 5.
7. missing call to notifiers in ipoib_vlan_delete() (Roland)
	It seems like you're right. I will fix and resend.

I think that if there are no other comments, I will submit the entire 11 patches 
again (with changes) to make it easier to merge into the kernel. Since the most of the 
content in the patch series is in bonding I thought it would be right that Jay will 
push all the patches to the networking git. Is it OK with you Roland?




 
