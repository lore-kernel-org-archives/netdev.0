From: "Glover George" <dime@gulfsales.com>
Subject: Obtaining the ip address of an interface dynamically
Date: Tue, 30 Apr 2002 11:48:05 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <001401c1f066$cce6c210$0300a8c0@yellow>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: <linux-net@vger.kernel.org>
List-Id: netdev.vger.kernel.org

Hi, I'm working on a little module here and was wondering what the BEST
way to get an interface's current ip address by using it's name (i.e.,
eth0) is.  I was trying one way using sockets and it just doesn't seem
to reliably give it to me every time.  I was using these two functions
below, but I it would return NULL some of the time from
IPCon_GetIpAddrByStr sometimes, so I'm not sure.  I need a way to be
able to reliably obtain this ip at any give time (due to dhcp, etc). Any
pointers?  TIA.


struct in_addr * IPCon::IPCon_GetIpAddr(void)
{
        struct ifreq ifr;
        struct sockaddr_in *saddr;
        int fd;
        fd = get_sockfd();
        if (fd >= 0 )
        {
                strcpy(ifr.ifr_name, m_ifname);
                ifr.ifr_addr.sa_family = AF_INET;
                if (ioctl(fd, SIOCGIFADDR, &ifr) == 0)
                {
                        saddr = (sockaddr_in *)&ifr.ifr_addr;
                        return &saddr->sin_addr;
                }
                else
                {
                        close(fd);
                        return NULL;
                }
        }
        return NULL;
}

char * IPCon::IPCon_GetIpAddrStr(void)
{
        /*struct in_addr *adr;
        adr = IPCon_GetIpAddr();
        if (adr == NULL)
                return NULL;
        else
                return inet_ntoa(*adr);*/
        return "208.164.149.42";
}

