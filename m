From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: [Bonding-devel] Re: Bonding driver unreliable under high CPUload
Date: Tue, 17 Sep 2002 16:11:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D878C56.2070400@mandrakesoft.com>
References: <72A87F7160C0994D8C5A36E2FDC227F502B3E70D@txnexc01.americas.cpqcorp.net> <3D878675.3000403@mandrakesoft.com> <3D878841.EB580DE9@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Cureington, Tony" <tony.cureington@hp.com>,
   Pascal Brisset <pascal.brisset-ml@wanadoo.fr>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Jeff Garzik wrote:
> 
>>...
>>Also, a further question:  do you have access to the slave struct
>>net_device?  If so, just test netif_carrier_ok(slave_dev) and avoid all
>>that ioctl calling if it returns non-zero.
> 
> 
> Make that "avoid all that ioctl calling from interrupt context", which
> is a bug.  Of the box-killing variety ;)


Indeed.  /me looks at the bond_check_dev_link callers more closely and 
shudders.

That wants fixing...

Note that netif_carrier_ok() can indeed be checked in interrupt context. 
  And if someone wants to send me patches converting more drivers to use 
netif_carrier_{on,off}, I would be very happy :)
