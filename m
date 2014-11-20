From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: i40e/i40e_ethtool.c weirdness?
Date: Thu, 20 Nov 2014 14:21:47 -0500
Message-ID: <51793.1416511307@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1416511307_39511P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1416511307_39511P
Content-Type: text/plain; charset=us-ascii

(spotted while looking at a 'git bisect visualize' for something else)

After this commit:

Author: Mitch Williams <mitch.a.williams@intel.com>  2014-09-13 03:40:47
Committer: Jeff Kirsher <jeffrey.t.kirsher@intel.com>  2014-10-23 23:38:04

    i40e: Add 10GBaseT support

    Add driver support for 10GBaseT device.

we have the following chunk of code in i40e_ethtool.c:

        case I40E_PHY_TYPE_10GBASE_SFPP_CU:
                ecmd->supported = SUPPORTED_10000baseT_Full;
                break;
        case I40E_PHY_TYPE_1000BASE_KX:
        case I40E_PHY_TYPE_1000BASE_T:
                ecmd->supported = SUPPORTED_Autoneg |
                                  SUPPORTED_10000baseT_Full |
                                  SUPPORTED_1000baseT_Full |
                                  SUPPORTED_100baseT_Full;
                ecmd->advertising = ADVERTISED_Autoneg |
                                    ADVERTISED_10000baseT_Full |
                                    ADVERTISED_1000baseT_Full |
                                    ADVERTISED_100baseT_Full;
                break;
        case I40E_PHY_TYPE_100BASE_TX:
                ecmd->supported = SUPPORTED_Autoneg |
                                  SUPPORTED_10000baseT_Full |
                                  SUPPORTED_1000baseT_Full |
                                  SUPPORTED_100baseT_Full;
                ecmd->advertising = ADVERTISED_Autoneg |
                                    ADVERTISED_10000baseT_Full |
                                    ADVERTISED_1000baseT_Full |
                                    ADVERTISED_100baseT_Full;
                break;
        case I40E_PHY_TYPE_SGMII:
                ecmd->supported = SUPPORTED_Autoneg |

I'm confused by the fact that 2 cases that by name are 100M and 1G parts
got bits saying that 10G is "supported" - was that intentional?


--==_Exmh_1416511307_39511P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVG4/SwdmEQWDXROgAQLgjQ/+L2qhxanGR07/AnEpt6AgcW5jTmlYe7A1
24yIsR/BSsQBhnY2Du7OmlP5BFfMRONU+gEpVRha+ydhNyhJdfBFgy/9hWjATH/M
Zu/C2H74shG7aXS8LsuOpgPOXndgMukYtwsBNCH/5h7I8ndVbjBGIUbcmd0auA5K
lCT7JTrUX4m+QQzyuR06Irwl+XcyhVTuqtjWmtWBmjVqVeMJ4rJG4eoZCHd0FT/c
AE6C+CoaesLQ2cM5QAQX8HInuHBFdT7dllHe3SumjiBzkUKkr2QWWUDIzc0FJXTe
Qs8fizKEgobqZ9IeMpnoXY32hKzrQGon4yLERGZX+VOMHZKqIKimVZ38ujpvfvib
9ocX8oWYdeCfyLgZy5TZag7oqjctMA/TIcfvWuu7A1XSMJsgMU7nZXRiBm5GUV56
qJm1t1/l3pbEhKN9YxKJJPoeH/BufnFkgo6zNuMacg8foSwtfhY8HZFBHNf2fDgP
Z7BB54e/v+0ZzZd8NZ8btYdfpAsJtqNPws97vASHO+EH2lAKWiNxFbcsM8BcG18M
GjBBhE/mi/dL4dkLEtebBoIQ67kfkw5Hg/xCDaB8lZ3+t2x3FPTC5hofQty6q5a8
px7SY8wF7IXWWeEjEr4XE+MVO37+uW0UZRHzgdqnKTkVT64NnKbx7QCheQ1fCgD9
mRi6ms7KPms=
=oct8
-----END PGP SIGNATURE-----

--==_Exmh_1416511307_39511P--
