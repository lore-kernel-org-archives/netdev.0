From: Marcel Holtmann <marcel@holtmann.org>
Subject: Problem with "ESP: sha1 digestsize 20 != 0"
Date: Thu, 03 Feb 2005 21:04:33 +0100
Message-ID: <1107461073.6833.8.camel@pegasus>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Network Development Mailing List <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

when using my RAS account with 2.6.11-rc3, I see a lot of

	ESP: sha1 digestsize 20 != 0

messages in my logs and the IPsec tunnel is not working. I tracked the
problem down to the change below. After reverting this patch, everything
works like before.

Regards

Marcel


ChangeSet@1.1830.738.7, 2005-01-25 21:53:42-08:00, herbert@gondor.apana.org.au
  [XFRM]: Probe selected algorithm only.
  
  This patch removes an annoying problem in xfrm_user.  As it is every
  time an SA is added it probes every known algorithm in the universe.
  Now if they all existed it would be OK.  However, for the ones which
  don't actually exist this causes multiple /sbin/modprobe processes to
  be spawned which slows the system down when you're adding hundreds of
  SAs.
  
  Since we know the type of algorithm required when we're adding a new
  SA, we can get away with only probing the selected algorithms.  This
  is what the following patch does for xfrm_user.
