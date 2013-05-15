From: Ricardo =?utf-8?b?VHViw61v?= <rtpardavila@gmail.com>
Subject: Single socket with =?utf-8?b?VFhfUklORw==?= and =?utf-8?b?UlhfUklORw==?=
Date: Wed, 15 May 2013 12:53:55 +0000 (UTC)
Message-ID: <loom.20130515T144941-798@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:44827 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932536Ab3EONFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 09:05:06 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UcbOB-0001CY-4P
	for netdev@vger.kernel.org; Wed, 15 May 2013 15:05:03 +0200
Received: from static-adsl-c-5-188.ipcom.comunitel.net ([static-adsl-c-5-188.ipcom.comunitel.net])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 15:05:03 +0200
Received: from rtpardavila by static-adsl-c-5-188.ipcom.comunitel.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 15:05:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once I tell kernel to export the TX_RING through setsockopt() (see code
below) I always get an error (EBUSY) if i try to tell kernel to export the
RX_RING with the same socket descriptor. Therefore, I have to open an
additional socket for the RX_RING and I require of two sockets when I though
that I would only require of one socket for both TX and RX using mmap()ed
memory.

Do I need both sockets or am I doing something wrong?

Code: 

/* init_ring; type = {PACKET_TX_RING, PACKET_RX_RING} */
void *init_ring(const int socket_fd, const int type)
{
  	
	void *ring = NULL;

	int ring_access_flags = PROT_READ | PROT_WRITE;
	tpacket_req_t *p = init_tpacket_req(FRAMES_PER_RING);
	int ring_len = ( p->tp_block_size ) * ( p->tp_block_nr );
  	
  	if ( setsockopt(socket_fd, SOL_PACKET, type,
                          p, LEN__TPACKET_REQ) < 0 )
	{
		log_sys_error("Setting socket options for this ring");
	}

	// 2) open ring
  	if ( ( ring = mmap(NULL, ring_len, ring_access_flags, MAP_SHARED,
  						socket_fd, 0) ) == NULL )
	{
		log_sys_error("mmap()ing error");
	}
	
	return(ring);
	
}
