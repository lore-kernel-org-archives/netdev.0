From: Jeff Garzik <jgarzik@pobox.com>
Subject: The recent free_netdev() conversion...
Date: Mon, 01 Sep 2003 10:59:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F535EBD.6090401@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Note that a lot of error paths were not caught.  In the typical driver 
you have:

->probe()

	dev = alloc_etherdev()
	blah_probe()
	if blah_probe() fails
		goto err_out
	register_netdev()
	return 0;

     err_out:
	kfree(dev);


->remove()
	free_netdev(dev);



The "kfree" needs to be a free_netdev() too.

	Jeff
