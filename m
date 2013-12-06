From: Sasha Levin <sasha.levin@oracle.com>
Subject: net: irda: hang when doing anything to a socket in accept()
Date: Fri, 06 Dec 2013 16:04:26 -0500
Message-ID: <52A23BDA.9000303@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: samuel@sortiz.org, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I've noticed that once an IRDA socket is in accept(), any further action that requires locking the
socket will result in a hang until accept() is completed (which may take a while). After a while
hung task spew is printed out.

		thread 1		|		thread 2
					|
	listen(sock)			|	
		bind(sock)		|
			accept(sock)	|
					|	setsockopt(sock)
						*HANG*	

I'm not sure I can provide a properly tested fix since I don't actually have IRDA hardware to test
on.


Thanks,
Sasha
