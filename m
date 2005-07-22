From: Steve French <smfltc@us.ibm.com>
Subject: Re: slow tcp acks on loopback device
Date: 22 Jul 2005 16:42:40 -0500
Message-ID: <1122068559.29257.32.camel@stevef95.austin.ibm.com>
References: <1122062219.29258.12.camel@stevef95.austin.ibm.com>
	<20050722.130816.91445335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samba-technical@lists.samba.org,
	linux-cifs-client@lists.samba.org
Return-path: <linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050722.130816.91445335.davem@davemloft.net>
List-Unsubscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/archive/linux-cifs-client>
List-Post: <mailto:linux-cifs-client@lists.samba.org>
List-Help: <mailto:linux-cifs-client-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=subscribe>
Sender: linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org
Errors-To: linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org
List-Id: netdev.vger.kernel.org


> TCP_NODELAY does not control ACK generation, instead it modifies
> the Nagle algorithm behavior when sending data packets.

Looks like RHEL4 had an odd default smb.conf on the server side - the
RedHat smb.conf seems to set SO_RCVBUF and SO_SNDBUF to 8K (reducing
them from their default). This seems very odd since common TCP frame
sizes for this protocol (SMB/CIFS) will be just over 16K (the negotiated
SMB buffer size) as well as even large frames, 60K, for large read/write
requests which Windows sends.  Removing the SO_SNDBUF, SO_RCVBUF options
(as in the smb.conf for other distros), increased performance a lot. 
The Samba Howto recommends against setting them so small as well.

The alternative solution configuring the client end - altering ack
behavior to allow the client to do quick(er) acks probably would have
helped too, but of course has sideeffects (more acks) and it was not
obvious to me how to do that safely from a kernel vfs module.
